# frozen_string_literal: true

require 'opal'
require 'snabberb'
require 'uglifier'
require 'zlib'

require_relative 'engine'
require_relative 'js_context'

class Assets
  OUTPUT_BASE = 'public'
  PIN_DIR = '/pinned/'

  def initialize(make_map: true, compress: false, gzip: false, cache: true, precompiled: false)
    @build_path = 'build'
    @out_path = OUTPUT_BASE + '/assets'
    @root_path = '/assets'

    @main_path = "#{@out_path}/main.js"
    @deps_path = "#{@out_path}/deps.js"

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

  def game_builds
    @game_builds ||= Dir['lib/engine/game/*/game.rb'].map do |dir|
      game = dir.split('/')[-2]
      path = "#{@out_path}/#{game}.js"
      build = {
        'path' => path,
        'files' => @precompiled ? [path] : [compile(nil, nil, nil, game: game)],
      }
      [game, build]
    end.to_h
  end

  def game_paths
    Dir["#{@out_path}/g_*.js"]
  end

  def builds
    @builds ||= {
      'deps' => {
        'path' => @deps_path,
        'files' => @precompiled ? [@deps_path] : [compile_lib('opal'), compile_lib('deps', 'assets')],
      },
      'main' => {
        'path' => @main_path,
        'files' => @precompiled ? [@main_path] : [compile('engine', 'lib', 'engine'), compile('app', 'assets/app', '')],
      },
      **game_builds,
    }
  end

  def js_tags(title)
    scripts = %w[deps main].map do |key|
      file = builds[key]['path'].gsub(@out_path, @root_path)
      %(<script type="text/javascript" src="#{file}"></script>)
    end
    scripts.concat(game_js_tags(title)).compact.join
  end

  def game_js_tags(title)
    return [] unless title

    game = Engine::GAMES_BY_TITLE[title]
    tags = game_js_tags(game::DEPENDS_ON)

    key = game.fs_name
    return [] unless builds.key?(key)

    file = builds[key]['path'].gsub(@out_path, @root_path)
    tags << %(<script type="text/javascript" src="#{file}"></script>)
    tags.compact
  end

  def combine
    @combine ||=
      begin
        unless @precompiled
          builds.each do |_key, build|
            source = build['files'].map { |file| File.read(file).to_s }.join

            if @compress
              time = Time.now
              source = Uglifier.compile(source, harmony: true)
              puts "Compressing - #{Time.now - time}"
            end

            File.write(build['path'], source)
            Zlib::GzipWriter.open("#{build['path']}.gz") { |gz| gz.write(source) } if @gzip
          end
        end
        [@deps_path, @main_path, *game_paths]
      end
  end

  def compile_lib(name, *append_paths)
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

  def compile(name, lib_path, ns = nil, game: nil)
    output = "#{@out_path}/#{name || game}.js"
    metadata = lib_metadata(ns || name, lib_path, game: game)

    compilers = metadata.map do |file, opts|
      FileUtils.mkdir_p(opts[:build_path])
      js_path = opts[:js_path]
      next if @cache && File.exist?(js_path) && File.mtime(js_path) >= opts[:mtime]

      Opal::Compiler.new(File.read(opts[:path]), file: file, requirable: true)
    end.compact

    return output if compilers.empty?

    if @make_map
      sm_path = "#{@build_path}/#{name || game}.json"
      sm_data = File.exist?(sm_path) ? JSON.parse(File.binread(sm_path)) : {}
    end

    compilers.each do |compiler|
      file = compiler.file
      raise "#{file} not found put in deps." unless (opts = metadata[file])

      time = Time.now
      File.write(opts[:js_path], compiler.compile)
      puts "Compiling #{file} - #{Time.now - time}"
      next unless @make_map

      source_map = compiler.source_map
      code = source_map.generated_code + "\n"
      sm_data[file] = {
        'lines' => code.count("\n"),
        'map' => source_map.to_h,
      }
    end

    File.write(sm_path, JSON.dump(sm_data)) if @make_map

    source_map = {
      version: 3,
      file: "#{name || game}.js",
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

    opal_load = game ? "engine/game/#{game}" : name
    source += "\nOpal.load('#{opal_load}')"

    source += to_data_uri_comment(source_map) if @make_map
    File.write(output, source)
    output
  end

  def lib_metadata(ns, lib_path, game: nil)
    metadata = {}

    dir_path = game ? "lib/engine/game/#{game}/**/*.rb" : "#{lib_path}/**/*.rb"
    Dir[dir_path].each do |file|
      if file.end_with?('/meta.rb')
        next if game
      elsif !game
        next unless file.start_with?("#{lib_path}/#{ns}")
        next if file =~ %r{^lib/engine/game/g_.*/}
      end

      mtime = File.new(file).mtime
      path = file.split('/')[0..-2].join('/')

      prefix = game ? 'lib' : lib_path
      metadata[file.gsub("#{prefix}/", '')] = {
        path: file,
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

  def pin(pin_path)
    @pin ||=
      begin
        time = Time.now

        prealphas = Engine::GAMES_BY_TITLE.values
                      .select { |g| g::DEV_STAGE == :prealpha }
                      .map { |g| "public/assets/#{g.fs_name}.js" }

        source = (combine - prealphas).map { |file| File.read(file).to_s }.join
        source = Uglifier.compile(source, harmony: true)

        File.write(pin_path.gsub('.gz', ''), source)

        Zlib::GzipWriter.open(pin_path) { |gz| gz.write(source) }
        FileUtils.rm(pin_path.gsub('.gz', ''))
        puts "Building #{pin_path} - #{Time.now - time}"
      end
  end
end
