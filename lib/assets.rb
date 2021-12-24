# frozen_string_literal: true

require 'opal'
require 'snabberb'
require 'tempfile'
require 'zlib'

require_relative 'engine'
require_relative 'js_context'

class Assets
  OUTPUT_BASE = 'public'
  PIN_DIR = '/pinned/'

  def initialize(compress: false, gzip: false, cache: true, precompiled: false)
    @build_path = 'build'
    @out_path = OUTPUT_BASE + '/assets'
    @root_path = '/assets'

    @main_path = "#{@out_path}/main.js"
    @deps_path = "#{@out_path}/deps.js"
    @server_path = "#{@out_path}/server.js"

    @cache = cache
    @compress = compress
    @gzip = gzip
    @precompiled = precompiled
  end

  def context
    combine
    @context ||= JsContext.new(@server_path)
  end

  def html(script, **needs)
    context.eval(Snabberb.html_script(script, **needs))
  end

  def game_builds
    @game_builds ||= Dir['lib/engine/game/*/game.rb'].to_h do |dir|
      game = dir.split('/')[-2]
      path = "#{@out_path}/#{game}.js"
      build = {
        'path' => path,
        'files' => @precompiled ? [path] : [compile(nil, nil, nil, game: game)],
      }
      [game, build]
    end
  end

  def game_paths
    Dir["#{@out_path}/g_*.js"]
  end

  def builds
    @builds ||=
      if @precompiled
        {
          'deps' => {
            'path' => @deps_path,
            'files' => [@deps_path],
          },
          'main' => {
            'path' => @main_path,
            'files' => [@main_path],
          },
          'server' => {
            'path' => @server_path,
            'files' => [@server_path],
          },
          **game_builds,
        }
      else
        opal = compile_lib('opal')
        deps = compile_lib('deps', 'assets')
        engine = compile('engine', 'lib', 'engine')
        app = compile('app', 'assets/app', '')
        game_files = game_builds.values.flat_map { |g| g['files'] }
        {
          'deps' => {
            'path' => @deps_path,
            'files' => [opal, deps],
          },
          'main' => {
            'path' => @main_path,
            'files' => [engine, app],
          },
          'server' => {
            'path' => @server_path,
            'files' => [opal, deps, engine, app, *game_files],
          },
          **game_builds,
        }
      end
  end

  def js_tags(titles)
    titles.delete('all')

    scripts = %w[deps main].map do |key|
      file = builds[key]['path'].gsub(@out_path, @root_path)
      %(<script type="text/javascript" src="#{file}"></script>)
    end
    scripts.concat(titles.flat_map { |title| game_js_tags(title) }.uniq).compact.join
  end

  def game_js_tags(title)
    return [] unless title

    game = Engine.meta_by_title(title)
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
        builds.each do |key, build|
          next if @precompiled

          source = build['files'].map { |file| File.read(file).to_s }.join("\n")
          source = compress(key, source) if @compress
          File.write(build['path'], source)

          next if !@gzip || build['path'] == @server_path

          Zlib::GzipWriter.open("#{build['path']}.gz") do |gz|
            # two gzipped files with identical contents look different to
            # tools like rsync if their mtimes are different; we don't want
            # rsync to deploy "new" versions of deps.js.gz, etc if they
            # haven't changed
            gz.mtime = 0
            gz.write(source)
          end
        end

        [@deps_path, @main_path, *game_paths]
      end
  end

  def compile_lib(name, *append_paths)
    builder = Opal::Builder.new
    append_paths.each { |ap| builder.append_paths(ap) }
    path = "#{@out_path}/#{name}.js"
    if !@cache || !File.exist?(path) || path == @deps_path
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

    compilers.each do |compiler|
      file = compiler.file
      raise "#{file} not found put in deps." unless (opts = metadata[file])

      time = Time.now
      File.write(opts[:js_path], compiler.compile)
      puts "Compiling #{file} - #{Time.now - time}"
    end

    source = metadata.map do |_file, opts|
      File.read(opts[:js_path]).to_s
    end.join("\n")

    opal_load = game ? "engine/game/#{game}" : name
    source += "\nOpal.load('#{opal_load}')"

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
        next if %r{^lib/engine/game/g_.*/}.match?(file)
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

  def pin(pin_path)
    @pin ||=
      begin
        prealphas = Engine::GAME_META_BY_TITLE
          .values
          .select { |g| g::DEV_STAGE == :prealpha }
          .map { |g| "public/assets/#{g.fs_name}.js" }

        source = (combine - prealphas).map { |file| File.read(file).to_s }.join
        source = compress('pin', source)
        File.write(pin_path.gsub('.gz', ''), source)
        Zlib::GzipWriter.open(pin_path) { |gz| gz.write(source) }
        FileUtils.rm(pin_path.gsub('.gz', ''))
      end
  end

  def compress(key, source)
    Tempfile.create([key, '.js']) do |file|
      file.write(source)
      file.rewind
      now = Time.now
      source = `esbuild #{file.path} --minify --log-level=error --target=es2019`
      puts "Compressing #{key} - #{Time.now - now}"
    end

    source
  end

  def clean_intermediate_output_files
    return if @precompiled

    if @gzip
      builds.each do |_, build|
        file = build['path']
        next if file == @server_path

        File.delete(file) if File.exist?(file)
      end
    end

    builds
      .flat_map { |_, build| build['files'] }
      .uniq
      .each { |file| File.delete(file) if File.exist?(file) }
  end
end
