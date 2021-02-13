# frozen_string_literal: true

require 'pry-byebug'
require 'pp'

class Mover
  CLASS_NAME_RE = /^\s+class (.*) < (.*)/
  OPTIONAL_RULES_START_RE = /OPTIONAL_RULES =/
  OPTIONAL_RULES_END_RE = /].freeze$/
  BRACKET_BRACE_EOL_RE = /((\s+).*)\[\{$/
  FIX_WHITESPACE_RE = /^(\s+)  \S/
  CLOSING_BRACKET_AT_START_RE = /^\]/
  CONFIG_IMPORT_RE = %r{^require_relative.*/config/}
  IMPORT_RE = /^require_relative '(.*)'/
  INCLUDE_RE = /^\s+include (.*)$/

  METADATA_CONSTANTS = %i[
    GAME_DESIGNER
    GAME_IMPLEMENTER
    GAME_INFO_URL
    GAME_LOCATION
    GAME_PUBLISHER
    GAME_RULES_URL
    GAME_TITLE
  ].freeze

  attr_reader :name, :module_name, :old_game_file, :game_class, :game_config_json
  attr_accessor :files_new_to_old, :files_old_to_new

  def initialize(name, depends_on: {})
    @name = name
    @depends_on = depends_on

    @old_game_file = "lib/engine/game/#{name}.rb"
    @stub_file = "lib/engine/game/#{name}.rb"
    @old_config_file = "lib/engine/config/game/#{name}.rb"
    @module_name = init_module_name(@old_game_file)

    @new_game_dir = "lib/engine/game/#{name}"

    @game_class = Engine::Game.const_get(@module_name)
    @game_config_json =
      begin
        if @name == 'g_18_los_angeles'
          [Engine::Config::Game::G18LosAngeles::JSON, Engine::Config::Game::G1846::JSON]
        else
          [Engine::Config::Game.const_get("#{@module_name}::JSON")]
        end
      rescue StandardError
        nil
      end

    @files_new_to_old = {}
    @files_old_to_new = {}

    @child_movers = Engine::GAME_METAS
                      .select { |g| g.is_a?(Class) && g.superclass == @game_class }
                      .map(&:fs_name)
                      .map { |n| Mover.new(n, depends_on: { title: @game_class.title, module_name: @module_name }) }
  end

  def move!
    return puts "Dirty workspace, won't move" unless system('git diff --quiet')

    begin
      move_config_into_game

      move_files

      create_stub_file

      create_meta_file

      rewrite_game_file
      rewrite_other_files

      puts 'Running rubocop...'
      # rubocop's auto-correct leaves a few things weird, but we can make some
      # changes to help it out; after a few iterations it looks reasonable
      `bundle exec rubocop -A #{@stub_file} #{@new_game_dir}/ > /dev/null 2>&1`
      2.times do
        rubocop_assist(file: meta_file)
        rubocop_assist(file: game_file)
        `bundle exec rubocop -A #{@new_game_dir}/ > /dev/null 2>&1`
      end

      puts 'Committing...'
      `git add -u lib/engine/game/#{name}*`
      `git commit -m "rake move_game[#{name}]"`

      nil
    rescue StandardError => e
      puts 'Encountered error, cleaning git workspace'
      `git reset --quiet`
      `git checkout --quiet .`
      `rm -rf #{@new_game_dir}/`

      puts e
      puts e.backtrace
    end

    @child_movers.each do |mover|
      mover.files_new_to_old = @files_new_to_old.dup
      mover.files_old_to_new = @files_old_to_new.dup
      mover.move!
    end
  end

  def game_file
    @game_file ||= "#{@new_game_dir}/game.rb"
  end

  def meta_file
    @meta_file ||= "#{@new_game_dir}/meta.rb"
  end

  def init_module_name(file)
    File.read(file).split("\n")
      .lazy
      .map { |l| l.match(CLASS_NAME_RE)&.captures&.first }
      .find(&:itself)
  end

  def const_line(constant, value, strip: true)
    line = "#{constant} = #{value.pretty_inspect}"
    strip ? line.strip : line
  end

  # work on the old game file
  def move_config_into_game
    return unless @game_config_json

    puts 'Moving config JSON into Game class...'

    constants = load_from_json(*@game_config_json).map do |const_name, value|
      if value.nil? || (value.respond_to?(:empty?) && value.empty?)
        nil
      else
        const_line(const_name, value, strip: false)
      end
    end.compact

    lines = File.read(@old_game_file).split("\n")
    index = lines.index { |l| l =~ /load_from_json/ }

    lines[index] = constants.join("\n")

    File.write(@old_game_file, lines.join("\n"))

    `git rm #{@old_config_file}`
    `git add #{@old_game_file}`
  end

  def move_file(src, dest)
    FileUtils.mkdir_p(File.dirname(dest))
    `git mv #{src} #{dest}`
    @files_new_to_old[dest] = src
    @files_old_to_new[src] = dest
  end

  def move_files
    puts "Moving files into #{@new_game_dir}/..."
    move_file(@old_game_file, game_file)

    Dir['lib/engine/**/*.rb'].each do |old_file|
      next unless old_file =~ %r{/#{name}/}
      next if old_file =~ %r{#{@new_game_dir}/}

      file = old_file.sub("/#{name}/", '/').sub('lib/engine', "lib/engine/game/#{name}")
      move_file(old_file, file)
    end
  end

  # this is called before editing any files, but after they have moved
  def create_stub_file
    puts "Creating lib/engine/game/#{name}.rb..."

    text = <<~STUB
            # frozen_string_literal: true
      #{'      '}
            module Engine
              module Game
                module #{module_name}
                end
              end
            end
    STUB

    File.write("lib/engine/game/#{name}.rb", text)
    `git add lib/engine/game/#{name}.rb`
  end

  def create_meta_file
    puts "Creating lib/engine/game/#{name}/meta.rb..."

    platform_constants = [
      const_line('DEV_STAGE', @game_class::DEV_STAGE),
    ]
    platform_constants << const_line('DEPENDS_ON', @depends_on[:title]) if @depends_on[:title]

    metadata_constants = METADATA_CONSTANTS.map do |constant|
      value = @game_class.const_get(constant)
      const_line(constant, value) if value != Engine::Game::Meta.const_get(constant)
    end.compact
    if File.read(game_file).include?('def self.title')
      metadata_constants << "GAME_TITLE = #{@game_class.title.pretty_inspect}"
    end

    rules_constants = [
      const_line('PLAYER_RANGE', Engine.player_range(@game_class)),
    ]
    optional_rules = @game_class::OPTIONAL_RULES
    rules_constants << const_line('OPTIONAL_RULES', optional_rules) unless optional_rules.empty?

    text = <<~META
            # frozen_string_literal: true
      #{'      '}
            require_relative '../meta'
      #{'      '}
            module Engine
              module Game
                module #{module_name}
                  module Meta
                    include Game::Meta
      #{'      '}
                    #{platform_constants.join("\n")}
      #{'      '}
                    #{metadata_constants.join("\n")}
      #{'      '}
                    #{rules_constants.join("\n")}
                  end
                end
              end
            end
    META

    File.write("#{@new_game_dir}/meta.rb", text)
    `git add #{@new_game_dir}/meta.rb`
  end

  # adapted from Game::Base.load_from_json
  def load_from_json(*jsons)
    data = Array(jsons).reverse.reduce({}) do |memo, json|
      memo.merge!(JSON.parse(json))
    end

    # Make sure player objects have numeric keys
    data['bankCash'].transform_keys!(&:to_i) if data['bankCash'].is_a?(Hash)
    data['certLimit'].transform_keys!(&:to_i) if data['certLimit'].is_a?(Hash)
    data['startingCash'].transform_keys!(&:to_i) if data['startingCash'].is_a?(Hash)

    data['phases'].map! do |phase|
      phase.transform_keys!(&:to_sym)
      phase[:tiles]&.map!(&:to_sym)
      phase[:events]&.transform_keys!(&:to_sym)
      phase[:train_limit].transform_keys!(&:to_sym) if phase[:train_limit].is_a?(Hash)
      phase
    end

    data['trains'].map! do |train|
      train.transform_keys!(&:to_sym)
      train[:variants]&.each { |variant| variant.transform_keys!(&:to_sym) }
      train
    end

    data['companies'] ||= []

    data['companies'].map! do |company|
      company.transform_keys!(&:to_sym)
      company[:abilities]&.each { |ability| ability.transform_keys!(&:to_sym) }
      company[:color] = @game_class.const_get(:COLORS)[company[:color]&.to_sym] if @game_class.const_defined?(:COLORS)
      company
    end

    data['minors'] ||= []

    data['minors'].map! do |minor|
      minor.transform_keys!(&:to_sym)
      minor[:color] = @game_class.const_get(:COLORS)[minor[:color]&.to_sym] if @game_class.const_defined?(:COLORS)
      minor[:abilities]&.each { |ability| ability.transform_keys!(&:to_sym) }
      minor
    end

    data['corporations'].map! do |corporation|
      corporation.transform_keys!(&:to_sym)
      corporation[:abilities]&.each { |ability| ability.transform_keys!(&:to_sym) }
      corporation[:color] =
        @game_class.const_get(:COLORS)[corporation[:color]&.to_sym] if @game_class.const_defined?(:COLORS)
      corporation[:reservation_color] =
        @game_class.const_get(:COLORS)[corporation[:reservation_color]&.to_sym] if @game_class.const_defined?(:COLORS)
      corporation
    end

    data['hexes'].transform_keys!(&:to_sym)
    data['hexes'].transform_values!(&:invert)

    hex_ids = data['hexes'].values.map(&:keys).flatten

    dup_hexes = hex_ids.group_by(&:itself).select { |_, v| v.size > 1 }.keys
    raise GameError, "Found multiple definitions in #{self} for hexes #{dup_hexes}" if dup_hexes.any?

    {
      CURRENCY_FORMAT_STR: data['currencyFormatStr'],
      BANK_CASH: data['bankCash'],
      CERT_LIMIT: data['certLimit'] || nil,
      STARTING_CASH: data['startingCash'],
      CAPITALIZATION: data['capitalization'] ? data['capitalization'].to_sym : nil,
      MUST_SELL_IN_BLOCKS: data['mustSellInBlocks'],
      TILES: data['tiles'],
      LOCATION_NAMES: data['locationNames'],
      MARKET: data['market'],
      PHASES: data['phases'],
      TRAINS: data['trains'],
      COMPANIES: data['companies'],
      CORPORATIONS: data['corporations'],
      MINORS: data['minors'],
      HEXES: data['hexes'],
      LAYOUT: data['layout'].to_sym,
    }
  end

  def rewrite_game_file
    puts "Modifying #{game_file}..."

    lines = File.read(game_file).split("\n")

    # remove constants that exist in meta.rb
    (METADATA_CONSTANTS + [:DEV_STAGE]).each do |constant|
      index = lines.index { |l| l.match(/#{constant} = .*/) }
      next unless index

      line = lines[index]
      if line.match(/^\s+#{constant} = \{$/)
        index_end = index + lines[index..-1].index { |l| l.match(/\s+}.freeze$/) }
        lines.slice!(index..index_end)
      else
        lines.delete_at(index)
      end
    end
    optional_rules_start = lines.index { |l| l.match(OPTIONAL_RULES_START_RE) }
    if optional_rules_start
      optional_rules_end = optional_rules_start + lines[optional_rules_start..-1].index do |l|
        l.match(OPTIONAL_RULES_END_RE)
      end
      lines.slice!(optional_rules_start..optional_rules_end)
    end

    # custom title method replaced by GAME_TITLE in meta
    title_index = lines.index { |l| l.match(/def self.title$/) }
    lines.slice!(title_index..(title_index + 2)) if title_index

    lines.map! do |line|
      # ditch config, add meta
      if line.match(CONFIG_IMPORT_RE)
        "require_relative 'meta'"

      # other relative imports
      elsif (match = line.match(IMPORT_RE))
        update_import_line(match.captures.first, game_file)

      # fix class declaration, load in the meta file
      elsif (match = line.match(CLASS_NAME_RE))
        parent = match.captures[1]
        parent_class = parent == 'Base' ? 'Game::Base' : "#{parent}::Game"
        "module #{module_name} \n class Game < #{parent_class} \n load_from_meta(#{module_name}::Meta)\n"

      elsif (match = line.match(INCLUDE_RE))
        update_include_line(match.captures.first, game_file)

      elsif line.match(/Engine::#{@module_name}::/)
        line.sub("Engine::#{@module_name}", @module_name)

      else
        line = fix_const('Round', line)
        line = fix_const('Step', line)
        line
      end
    end

    # closing thing for the class declaration
    lines << 'end'

    File.write(game_file, lines.join("\n"))
  end

  def rewrite_other_files
    Dir["lib/engine/game/#{name}/**/*.rb"].each do |file|
      next if file == game_file
      next if file == meta_file

      puts "Modifying #{file}..."

      lines = File.read(file).split("\n")

      step_round = file.match(%r{lib/engine/game/#{name}/(?:(.*)/)?.*.rb}).captures.compact.first

      ends = 0
      lines.map! do |line|
        if (match = line.match(IMPORT_RE))
          update_import_line(match.captures.first, file)

        elsif step_round && line.match(/module #{step_round.capitalize}/)
          'module Game'

        elsif line == 'module Engine' && !step_round
          ends += 1
          "module Engine \n module Game"

        elsif (match = line.match(CLASS_NAME_RE))
          thing_class_name = match.captures[0]
          parent = match.captures[1]

          new_parent_class = ['Engine', step_round&.capitalize, parent].compact.join('::')
          new_parent_class.gsub!("#{step_round&.capitalize}::#{step_round&.capitalize}",
                                 step_round&.capitalize) if step_round

          new_line = ''
          if step_round
            ends += 1
            new_line = "module #{step_round.capitalize}\n"
          end
          new_line += "class #{thing_class_name} < #{new_parent_class}"

          new_line

        elsif (match = line.match(INCLUDE_RE))
          update_include_line(match.captures.first, file)

        else
          line = fix_const('Round', line)
          line = fix_const('Step', line)
          line
        end
      end

      ends.times { lines << 'end' }

      File.write(file, lines.join("\n"))
    end
  end

  def update_import_line(import_path, file)
    import_path += '.rb' unless import_path.end_with?('.rb')

    old_file_pathname = Pathname.new(@files_new_to_old[file])
    imported_file = old_file_pathname.dirname.join(import_path)

    # if the imported_file was a game file that has been moved, update to import
    # from its new location
    imported_file = Pathname.new(@files_old_to_new[imported_file.to_s]) if @files_old_to_new.key?(imported_file.to_s)

    new_import_path = imported_file.relative_path_from(File.dirname(file)).to_s
    new_import_path.sub!('.rb', '')

    "require_relative '#{new_import_path}'"
  end

  def update_include_line(included_module, file)
    const = const_from_file(file)
    new_module_name = const.ancestors.select { |a| a.name =~ /\b#{included_module}\b/ }.map(&:name)

    raise StandardError, "could not find matching module for #{included_module}" if new_module_name.empty?

    unless new_module_name.one?
      puts "    WARNING: found more than one possible module for #{included_module}: #{new_module_name.pretty_inspect}"
      return "# TODO: include one of: #{new_module_name}"
    end

    new_module_name = new_module_name.first

    parts = new_module_name.split('::')
    index = parts.index { |n| n == (module_name) }
    parts.slice!(0..index) if index
    new_module_name = parts.join('::')

    "include #{new_module_name}"
  end

  def const_from_file(file)
    return @game_class if file == @old_game_file

    old_file = @files_new_to_old[file]

    const_name = old_file.sub('.rb', '').split('/').slice(1..-1).map do |x|
      x.split('_').map(&:capitalize).join
    end.join('::')
    Engine.const_get(const_name)
  end

  def fix_const(kind, line)
    return line unless line =~ /#{kind}::/

    case line
    when /#{kind}::#{module_name}/
      line.gsub("#{kind}::#{module_name}", "#{module_name}::#{kind}")
    when /Engine::#{module_name}/
      line.gsub("Engine::#{module_name}", module_name.to_s)
    when /#{kind}::#{@depends_on[:module_name] || 'NO_DEPENDS_ON'}/
      line.gsub("#{kind}::#{@depends_on[:module_name]}", "#{@depends_on[:module_name]}::#{kind}")
    when /Engine::#{@depends_on[:module_name] || 'NO_DEPENDS_ON'}/
      line.gsub("Engine::#{@depends_on[:module_name]}", @depends_on[:module_name].to_s)
    when /[^a-zA-Z0-9]#{kind}::/
      if custom_code_for?(kind)
        line.gsub("#{kind}::", "Engine::#{kind}::")
      else
        line
      end
    else
      line
    end
  end

  def custom_code_for?(kind)
    filename = kind.downcase
    Dir["lib/engine/game/#{name}/#{filename}/**/*.rb", "lib/engine/game/#{name}/#{filename}.rb"].any?
  end

  def rubocop_assist(file:)
    lines = File.read(file).split("\n")

    lines = lines.each_with_index.map do |line, index|
      # fixes first hash in list being indented differently from rest, by
      # moving the opening brace for the first hash to the next line:
      #
      # OPTIONAL_RULES = [{
      #   sym: :short_squeeze,
      #   short_name: 'Short Squeeze',
      #   desc: 'Corporations with > 100% player ownership move a second time at end of SR',
      # },
      #                   {
      #                     sym: :five_shorts,
      #                     short_name: '5 Shorts',
      #                     desc: 'Only allow 5 shorts on 10 share corporations',
      #                   },
      if (match = line.match(BRACKET_BRACE_EOL_RE))
        "#{match.captures[0]}[\n#{match.captures[1]}  {"

      # fixes closing bracket having no indentation at all, by inferring the
      # indentation from the previous line:
      #
      #     OPTIONAL_RULES = [
      #       {
      #         sym: :short_squeeze,
      #         short_name: 'Short Squeeze',
      #         desc: 'Corporations with > 100% player ownership move a second time at end of SR',
      #       },
      #       {
      #         sym: :modern_trains,
      #         short_name: 'Modern Trains',
      #         desc: '7 & 8 trains earn $10 & $20 respectively for each station marker of the corporation',
      #       },
      # ].freeze
      elsif line.match(CLOSING_BRACKET_AT_START_RE)
        spaces = lines[index - 1].match(FIX_WHITESPACE_RE).captures.first
        spaces + line

      elsif (match = line.match(/((\s+)MARKET = \[)(%w\[.+)$/))
        "#{match.captures[0]}\n#{match.captures[1]}  #{match.captures[2]}"

      # nothing to fix for this line
      else
        line
      end
    end

    File.write(file, lines.join("\n"))
  end
end
