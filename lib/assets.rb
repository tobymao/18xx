# frozen_string_literal: true

require 'opal'
require 'snabberb'
require 'uglifier'
require 'zlib'

require_relative 'js_context'

class Assets
  def initialize(make_map: true, compress: false, gzip: false, cache: true, precompiled: false)
    @files = []
    @build_path = 'build'
    @out_path = 'public/assets'
    @root_path = '/assets'
    @bundle_path = "#{@out_path}/main.js"

    @cache = cache
    @make_map = make_map
    @compress = compress
    @gzip = gzip
    @precompiled = precompiled
  end

  def context
    @context ||= JsContext.new(combine)
  end

  def html(script, **needs)
    context.eval(Snabberb.html_script(script, **needs))
  end

  def build
    return [@bundle_path] if @precompiled

    @build ||= [
      compile_lib('opal'),
      compile_lib('deps', 'assets'),
      compile('engine', 'lib', 'engine'),
      compile('app', 'assets/app', ''),
    ]
  end

  def js_tags
    build.map do |file|
      file = file.gsub(@out_path, @root_path)
      %(<script type="text/javascript" src="#{file}"></script>)
    end.join
  end

  def combine
    @combine ||=
      begin
        unless @precompiled
          source = build.map { |file| File.read(file).to_s }.join
          if @compress
            time = Time.now
            source = Uglifier.compile(source, harmony: true)
            puts "Compressing - #{Time.now - time}"
          end
          File.write(@bundle_path, source)
          Zlib::GzipWriter.open("#{@bundle_path}.gz") { |gz| gz.write(source) } if @gzip
        end

        @bundle_path
      end
  end

  def compile_lib(name, *append_paths)
    @files << name
    builder = Opal::Builder.new
    append_paths.each { |ap| builder.append_paths(ap) }
    path = "#{@out_path}/#{name}.js"
    if !@cache || !File.exist?(path)
      time = Time.now
      File.write(path, builder.build(name))
      puts "Compiling #{name} - #{Time.now - time}"
    end
    path
  end

  def compile(name, lib_path, ns = nil)
    @files << name
    metadata = lib_metadata(ns || name, lib_path)

    stale = []
    fresh = []

    metadata.each do |file, opts|
      FileUtils.mkdir_p(opts[:build_path])
      js_path = opts[:js_path]

      if !@cache || !File.exist?(js_path) || File.mtime(js_path) < opts[:mtime]
        stale << file
      else
        fresh << file
      end
    end

    builder = Opal::Builder.new(prerequired: fresh, compiler_options: { requirable: true })
    builder.append_paths(lib_path)

    stale.each do |file|
      time = Time.now
      builder.build(file)
      puts "Compiling #{file} - #{Time.now - time}"
    end

    if @make_map
      sm_path = "#{@build_path}/#{name}.json"
      sm_data = File.exist?(sm_path) ? JSON.parse(File.binread(sm_path)) : {}
    end

    builder.processed.each do |processor|
      file = processor.filename.gsub('./', '')
      raise "#{file} not found put in deps." unless (opts = metadata[file])

      File.write(opts[:js_path], processor.to_s)
      next unless @make_map

      source_map = processor.source_map
      code = source_map.generated_code + "\n"
      sm_data[file] = {
        'lines' => code.count("\n"),
        'map' => source_map.to_h,
      }
    end

    File.write(sm_path, JSON.dump(sm_data)) if @make_map

    source_map = {
       version: 3,
       file: "#{name}.js",
       sections: [],
    }

    offset_line = 0

    source = metadata.map do |file, opts|
      if @make_map
        sm = sm_data[file]

        source_map[:sections] << {
          offset: {
            line: offset_line,
            column: 0,
          },
          map: sm['map'],
        }

        offset_line += sm['lines']
      end

      File.read(opts[:js_path]).to_s
    end.join("\n")
    source += "\nOpal.load('#{name}')"
    source += to_data_uri_comment(source_map) if @make_map
    output = "#{@out_path}/#{name}.js"
    File.write(output, source)
    output
  end

  def lib_metadata(ns, lib_path)
    metadata = {}

    Dir["#{lib_path}/**/*.rb"].each do |file|
      next unless file.start_with?("#{lib_path}/#{ns}")

      mtime = File.new(file).mtime
      path = file.split('/')[0..-2].join('/')

      metadata[file.gsub("#{lib_path}/", '')] = {
        path: path,
        build_path: "#{@build_path}/#{path}",
        js_path: "#{@build_path}/#{file.gsub('.rb', '.js')}",
        mtime: mtime,
      }
    end

    metadata
  end

  def to_data_uri_comment(source_map)
    map_json = JSON.dump(source_map)
    "//# sourceMappingURL=data:application/json;base64,#{Base64.encode64(map_json).delete("\n")}"
  end
end
