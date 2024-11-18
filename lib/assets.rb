# frozen_string_literal: true

require 'json'
require 'opal'
require 'snabberb'
require 'tempfile'
require 'zlib'

require_relative 'engine'
require_relative 'js_context'

class Assets
  OUTPUT_BASE = 'public'
  PIN_DIR = '/pinned/'

  class SourceMap
    def initialize
      @source_map = {
        'version' => 3,
        'sections' => [],
      }
      @current_line = 0
    end

    def append(file_contents, source_map_file)
      @source_map['sections'].append({
                                       'offset' => { 'line' => @current_line, 'column' => 0 },
                                       'map' => JSON.parse(File.read(source_map_file)),
                                     })
      @current_line += file_contents.lines.count + 1
    end

    def extend(file_contents, source_map_file)
      file_source_map = JSON.parse(File.read(source_map_file))
      file_source_map['sections'].each do |section|
        @source_map['sections'].append({
                                         'offset' => { 'line' => @current_line + section['offset']['line'], 'column' => 0 },
                                         'map' => section['map'],
                                       })
      end
      @current_line += file_contents.lines.count + 1
    end

    def to_json(*args)
      @source_map.to_json(*args)
    end
  end

  def initialize(compress: false, gzip: false, cache: true, precompiled: false, source_maps: false)
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
    @source_maps = source_maps
  end

  def context(titles)
    combine(titles)
    @context ||= JsContext.new(@server_path)
  end

  def html(script, titles: :all, **needs)
    context(titles).eval(Snabberb.html_script(script, **needs))
  end

  def game_builds(titles = [])
    all_titles = Dir['lib/engine/game/*/game.rb'].map do |dir|
      dir.split('/')[-2]
    end

    if @precompiled || titles == :all
      build_titles = all_titles
    else
      build_titles = titles_with_ancestors(titles)

      # create empty stubs of all other game titles for the roda :assets
      # plugin
      stub_titles = all_titles - build_titles
      stub_titles.each do |title|
        game = to_fs_name(title)
        filename = "#{@out_path}/#{game}.js"
        next if File.exist?(filename)

        File.write(filename, '')
        file = File.new(filename)
        FileUtils.touch(file, mtime: 0)
        puts "Stubbing #{filename}"
      end
    end

    build_titles.to_h do |title|
      # convert `title` to "g_1889" format
      game = to_fs_name(title)

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

  def builds(titles = [])
    if @precompiled
      @builds ||= {
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
        **game_builds(:all),
      }
    else
      @_opal ||= compile_lib('opal', 'opal')
      @_deps ||= compile_lib('deps_only', 'deps', 'assets')
      @_engine ||= compile('engine', 'lib', 'engine')
      @_app ||= compile('app', 'assets/app', '')

      g_builds = game_builds(titles)
      game_files = g_builds.values.flat_map { |g| g['files'] }

      {
        'deps' => {
          'path' => @deps_path,
          'files' => [@_opal, @_deps],
        },
        'main' => {
          'path' => @main_path,
          'files' => [@_engine, @_app],
        },
        'server' => {
          'path' => @server_path,
          'files' => [@_opal, @_deps, @_engine, @_app, *game_files],
        },
        **g_builds,
      }
    end
  end

  def js_tags(titles = [])
    combine(titles)

    scripts = %w[deps main].map do |key|
      file = builds(titles)[key]['path'].gsub(@out_path, @root_path)
      %(<script type="text/javascript" src="#{file}"></script>)
    end
    scripts.concat(titles.flat_map { |title| game_js_tags(title) }.uniq).compact.join
  end

  def game_js_tags(title)
    return [] unless title

    titles = title_with_ancestors(title)
    builds_for_games = builds(titles)

    titles.each_with_object([]) do |game_title, _tags|
      key = to_fs_name(game_title)
      next unless builds_for_games.key?(key)

      file = builds_for_games[key]['path'].gsub(@out_path, @root_path)
      %(<script type="text/javascript" src="#{file}"></script>)
    end
  end

  def combine(titles = [])
    @_combined ||= Set.new

    combine_titles =
      if titles == :all
        :all
      else
        titles_with_ancestors(titles)
      end

    builds(combine_titles).each do |key, build|
      next if @precompiled

      @_combined.include?(key) ? next : @_combined.add(key)

      source_map = SourceMap.new
      source = build['files'].map do |filepath|
        file = File.read(filepath).to_s
        source_map.extend(file, filepath + '.map') if @source_maps
        file
      end.join("\n")
      source += "\n//# sourceMappingURL=#{build['path'].delete_prefix('public')}.map\n" if @source_maps

      source = compress(key, source) if @compress
      File.write(build['path'], source)
      File.write(build['path'] + '.map', source_map.to_json) if @source_maps

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

  def compile_lib(output_name, name, *append_paths)
    builder = Opal::Builder.new
    append_paths.each { |ap| builder.append_paths(ap) }
    path = "#{@out_path}/#{output_name}.js"
    if !@cache || !File.exist?(path)
      time = Time.now
      File.write(path, builder.build(name))
      File.write("#{path}.map", builder.source_map.map.to_json) if @source_maps
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
      File.write(opts[:js_path] + '.map', compiler.source_map.map.to_json) if @source_maps
      puts "Compiling #{file} - #{Time.now - time}"
    end

    source_map = SourceMap.new
    source = metadata.map do |_file, opts|
      file = File.read(opts[:js_path])
      source_map.append(file, opts[:js_path] + '.map') if @source_maps
      file
    end.join("\n")

    opal_load = game ? "engine/game/#{game}" : name
    source += "\nOpal.load('#{opal_load}')"

    File.write(output, source)
    File.write(output + '.map', source_map.to_json) if @source_maps
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

  def to_fs_name(title)
    Engine.meta_by_title(title).fs_name
  end

  # returns an array of game titles, starting with the earliest ancestor and
  # ending with the given game, e.g.,
  # `title_with_ancestors('1822CA WRS') -> ['1822', '1822CA', '1822CA WRS']`
  def title_with_ancestors(title)
    return [] unless (game = Engine.meta_by_title(title))

    [*title_with_ancestors(game::DEPENDS_ON), title]
  end

  def titles_with_ancestors(titles)
    titles.flat_map { |t| title_with_ancestors(t) }.uniq
  end
end
