# frozen_string_literal: true

require 'opal'
require 'tilt/opal'

class OpalTemplate < Opal::TiltTemplate
  BUILD_PATH = 'build'
  OPAL_PATH = "#{BUILD_PATH}/compiled-opal.js"
  def evaluate(_scope, _locals)
    File.write(OPAL_PATH, Opal::Builder.build('opal')) unless File.exist?(OPAL_PATH)
    compile('engine', 'lib')

    builder = Opal::Builder.new(stubs: ['opal'])
    builder.append_paths('assets/js')
    builder.append_paths('build')
    content = builder.build(file).to_s

    return content if ENV['RACK_ENV'] == 'production'

    content_with_source_map(content, builder.source_map)
  end

  def content_with_source_map(content, source_map)
    "#{content}\n#{to_data_uri_comment(source_map.to_json)}"
  end

  def to_data_uri_comment(map_json)
    "//# sourceMappingURL=data:application/json;base64,#{Base64.encode64(map_json).delete("\n")}"
  end

  def lib_metadata(name, lib_path)
    metadata = {}

    Dir["#{lib_path}/**/*.rb"].each do |file|
      next unless file.start_with?("#{lib_path}/#{name}")

      mtime = File.new(file).mtime
      path = file.split('/')[0..-2].join('/')

      metadata[file.gsub("#{lib_path}/", '')] = {
        path: path,
        build_path: "#{BUILD_PATH}/#{path}",
        js_path: "#{BUILD_PATH}/#{file.gsub('.rb', '.js')}",
        mtime: mtime,
      }
    end

    metadata
  end

  def compile(name, lib_path)
    metadata = lib_metadata(name, lib_path)

    stale = []
    fresh = []

    metadata.each do |file, opts|
      FileUtils.mkdir_p(opts[:build_path])
      js_path = opts[:js_path]
      !File.exist?(js_path) || File.mtime(js_path) < opts[:mtime] ? stale << file : fresh << file
    end

    builder = Opal::Builder.new(prerequired: fresh, compiler_options: { requirable: true })
    builder.append_paths(lib_path)
    stale.each do |file|
      time = Time.now
      builder.build(file)
      puts "Recompiling #{file} - #{Time.now - time}"
    end

    builder.processed.each do |processor|
      file = processor.filename.gsub('./', '')
      opts = metadata[file]

      required_trees = processor.required_trees.flat_map do |rel_path|
        path = File
          .expand_path("#{opts[:path]}/#{rel_path}")
          .partition(name + '/')[1..-1]
        Dir["#{path}/**/*.rb"]
      end

      File.write(opts[:js_path], processor.to_s)
    end

    source = metadata
      .map { |_, opts| "#{File.read(opts[:js_path]).to_s}" }
      .join("\n")

    File.write("#{BUILD_PATH}/#{name}.js", source + "\nOpal.load('#{name}')")
  end

end

Tilt.register 'rb', OpalTemplate
