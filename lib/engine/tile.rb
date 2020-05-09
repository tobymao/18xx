# frozen_string_literal: true

require_relative 'game_error'
require_relative 'part/city'
require_relative 'part/town'
require_relative 'part/edge'
require_relative 'part/junction'
require_relative 'part/label'
require_relative 'part/offboard'
require_relative 'part/path'
require_relative 'part/upgrade'

module Engine
  class Tile
    # * [t]own     - [r]evenue, local_[id] (default: 0)
    # * [c]ity     - [r]evenue, local_[id] (default: 0), [s]lots (default 1)
    # * [o]ffboard - [r]evenues for different phases (separated by "/")
    # * [p]ath     - endpoints [a] and [b]; the endpoints can be an edge number,
    #                town/city/offboard reference, or a lawson-style [j]unction
    # * [l]abel    - large letters on tile
    # * [u]pgrade  - [c]ost, [t]errain (multiple terrain types separated by "+"),

    # [r]evenue    - number, list of numbers separated by "/", or something like
    #                yellow_30|brown_60|diesel_100

    # rubocop:disable Layout/LineLength
    WHITE = {
      'blank' => '',
      'town' => 't=r:0',
      'city' => 'c=r:0',
      'wtr40' => 'u=c:40,t:water',
      'mtn80' => 'u=c:80,t:mountain',
      'wtr80' => 'u=c:80,t:water',
      'mtn+wtr80' => 'u=c:80,t:mountain+water',
    }.freeze

    YELLOW = {
      '1' => 't=r:10;p=a:0,b:_0;p=a:_0,b:4;t=r:10;p=a:1,b:_1;p=a:_1,b:3',
      '2' => 't=r:10;p=a:0,b:_0;p=a:_0,b:3;t=r:10;p=a:4,b:_1;p=a:_1,b:5',
      '3' => 't=r:10;p=a:0,b:_0;p=a:_0,b:1',
      '4' => 't=r:10;p=a:0,b:_0;p=a:_0,b:3',
      '5' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:1',
      '6' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:2',
      '7' => 'p=a:0,b:5',
      '8' => 'p=a:0,b:4',
      '9' => 'p=a:0,b:3',
      '55' => 't=r:10;p=a:0,b:_0;p=a:_0,b:3;t=r:10;p=a:2,b:_1;p=a:_1,b:5',
      '56' => 't=r:10;p=a:0,b:_0;p=a:_0,b:4;t=r:10;p=a:3,b:_1;p=a:_1,b:5',
      '57' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:3',
      '58' => 't=r:10;p=a:0,b:_0;p=a:_0,b:2',
      '69' => 't=r:10;p=a:1,b:_0;p=a:_0,b:4;t=r:10;p=a:3,b:_1;p=a:_1,b:5',
      '291' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:1;l=Z',
      '292' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:2;l=Z',
      '293' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:3;l=Z',
      '437' => 't=r:30;p=a:0,b:_0;p=a:_0,b:2;l=P',
      '438' => 'c=r:40;p=a:0,b:_0;p=a:_0,b:2;l=H;u=c:80',
      '630' => 't=r:10;p=a:1,b:_0;p=a:_0,b:2;t=r:10;p=a:3,b:_1;p=a:_1,b:5',
      '631' => 't=r:10;p=a:0,b:_0;p=a:_0,b:1;t=r:10;p=a:3,b:_1;p=a:_1,b:5',
      '632' => 't=r:10;p=a:0,b:_0;p=a:_0,b:5;t=r:10;p=a:3,b:_1;p=a:_1,b:4',
      '633' => 't=r:10;p=a:0,b:_0;p=a:_0,b:1;t=r:10;p=a:3,b:_1;p=a:_1,b:4',
      'X00' => 'c=r:30,s:1;p=a:0,b:_0;p=a:2,b:_0;p=a:4,b:_0;l=B',
      'X1' => 'c=r:30;p=a:0,b:_0;p=a:_0,b:4;l=DC',
    }.freeze

    GREEN = {
      '12' => 'c=r:30;p=a:0,b:_0;p=a:1,b:_0;p=a:5,b:_0',
      '13' => 'c=r:30;p=a:0,b:_0;p=a:2,b:_0;p=a:4,b:_0',
      '14' => 'c=r:30,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:3,b:_0;p=a:4,b:_0',
      '15' => 'c=r:30,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0',
      '16' => 'p=a:0,b:4;p=a:1,b:5',
      '17' => 'p=a:0,b:2;p=a:3,b:5',
      '18' => 'p=a:0,b:3;p=a:1,b:2',
      '19' => 'p=a:0,b:3;p=a:1,b:5',
      '20' => 'p=a:0,b:3;p=a:1,b:4',
      '21' => 'p=a:0,b:2;p=a:3,b:4',
      '22' => 'p=a:0,b:4;p=a:2,b:3',
      '23' => 'p=a:0,b:3;p=a:0,b:4',
      '24' => 'p=a:0,b:3;p=a:0,b:2',
      '25' => 'p=a:0,b:2;p=a:0,b:4',
      '26' => 'p=a:0,b:3;p=a:0,b:5',
      '27' => 'p=a:0,b:3;p=a:0,b:1',
      '28' => 'p=a:0,b:4;p=a:0,b:5',
      '29' => 'p=a:0,b:1;p=a:0,b:2',
      '30' => 'p=a:0,b:1;p=a:0,b:4',
      '31' => 'p=a:0,b:2;p=a:0,b:5',
      '54' => 'c=r:60,s:2;c=r:60,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:4,b:_1;p=a:5,b:_1;l=NY',
      '59' => 'c=r:40;c=r:40;p=a:0,b:_0;p=a:4,b:_1;l=OO',
      '80' => 'p=a:0,b:j;p=a:4,b:j;p=a:5,b:j',
      '81' => 'p=a:0,b:j;p=a:2,b:j;p=a:4,b:j',
      '81A' => 'p=a:0,b:j;p=a:2,b:j;p=a:4,b:j',
      '82' => 'p=a:0,b:j;p=a:3,b:j;p=a:4,b:j',
      '83' => 'p=a:0,b:j;p=a:3,b:j;p=a:5,b:j',
      '87' => 't=r:10;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0',
      '205' => 'c=r:30;p=a:0,b:_0;p=a:1,b:_0;p=a:3,b:_0',
      '206' => 'c=r:30;p=a:0,b:_0;p=a:3,b:_0;p=a:5,b:_0',
      '294' => 'c=r:40,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:4,b:_0;p=a:3,b:_0;l=Z',
      '295' => 'c=r:40,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;l=Z',
      '296' => 'c=r:40,s:2;p=a:0,b:_0;p=a:4,b:_0;p=a:2,b:_0;p=a:3,b:_0;l=Z',
      '298' => 'c=r:40;c=r:40;c=r:40;c=r:40;l=Chi;'\
               'p=a:1,b:_0;p=a:0,b:_1;p=a:5,b:_2;p=a:4,b:_3;'\
               'p=a:_0,b:3;p=a:_2,b:3;p=a:_3,b:3;p=a:_1,b:3',
      '439' => 'c=r:60,s:2;p=a:0,b:_0;p=a:2,b:_0;p=a:4,b:_0;l=H;u=c:80',
      '440' => 'c=r:40,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;l=T',
      '592' => 'c=r:50,s:2;p=a:0,b:_0;p=a:2,b:_0;p=a:4,b:_0;l=B',
      '619' => 'c=r:30,s:2;p=a:0,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0',
      'X2' => 'c=r:40,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=DC',
      'X3' => 'c=r:40;p=a:0,b:_0;p=a:_0,b:2;c=r:40;p=a:3,b:_1;p=a:_1,b:5;l=OO',
      'X4' => 'c=r:40;p=a:0,b:_0;p=a:_0,b:1;c=r:40;p=a:2,b:_1;p=a:_1,b:3;l=OO',
      'X5' => 'c=r:40;p=a:0,b:_0;p=a:_0,b:4;c=r:40;p=a:3,b:_1;p=a:_1,b:5;l=OO',
    }.freeze

    BROWN = {
      '39' => 'p=a:0,b:1;p=a:0,b:2;p=a:1,b:2',
      '40' => 'p=a:0,b:2;p=a:0,b:4;p=a:2,b:4',
      '41' => 'p=a:0,b:3;p=a:0,b:4;p=a:3,b:4',
      '42' => 'p=a:0,b:3;p=a:0,b:2;p=a:2,b:3',
      '43' => 'p=a:0,b:3;p=a:0,b:2;p=a:1,b:3;p=a:1,b:2',
      '44' => 'p=a:0,b:3;p=a:0,b:1;p=a:1,b:4;p=a:3,b:4',
      '45' => 'p=a:0,b:3;p=a:0,b:5;p=a:1,b:3;p=a:1,b:5',
      '46' => 'p=a:0,b:1;p=a:0,b:3;p=a:1,b:5;p=a:3,b:5',
      '47' => 'p=a:0,b:2;p=a:0,b:3;p=a:2,b:5;p=a:3,b:5',
      '62' => 'c=r:80,s:2;c=r:80,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:4,b:_1;p=a:5,b:_1;l=NY',
      '63' => 'c=r:40,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0',
      '64' => 'c=r:50;c=r:50;p=a:0,b:_0;p=a:2,b:_0;p=a:3,b:_1;p=a:4,b:_1;l=OO',
      '65' => 'c=r:50;c=r:50;p=a:0,b:_0;p=a:2,b:_0;p=a:4,b:_1;p=a:5,b:_1;l=OO',
      '66' => 'c=r:50;c=r:50;p=a:1,b:_0;p=a:2,b:_0;p=a:0,b:_1;p=a:3,b:_1;l=OO',
      '67' => 'c=r:50;c=r:50;p=a:1,b:_0;p=a:5,b:_0;p=a:0,b:_1;p=a:3,b:_1;l=OO',
      '68' => 'c=r:50;c=r:50;p=a:2,b:_0;p=a:5,b:_0;p=a:0,b:_1;p=a:3,b:_1;l=OO',
      '70' => 'p=a:0,b:2;p=a:0,b:1;p=a:1,b:3;p=a:2,b:3',
      '297' => 'c=r:60,s:3;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;l=Z',
      '299' => 'c=r:70;c=r:70;c=r:70;c=r:70;p=a:1,b:_0;p=a:2,b:_0;p=a:1,b:_1;p=a:3,b:_1;p=a:1,b:_2;p=a:4,b:_2;p=a:1,b:_3;p=a:5,b:_3;l=Chi',
      '448' => 'c=r:40,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0',
      '465' => 'c=r:60,s:3;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=K',
      '466' => 'c=r:60,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;l=T',
      '492' => 'c=r:80,s:3;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=H',
      '544' => 'p=a:0,b:j;p=a:1,b:j;p=a:3,b:j;p=a:4,b:j',
      '545' => 'p=a:0,b:j;p=a:1,b:j;p=a:2,b:j;p=a:3,b:j',
      '546' => 'p=a:0,b:j;p=a:2,b:j;p=a:3,b:j;p=a:4,b:j',
      '593' => 'c=r:60,s:3;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:4,b:_0;l=B',
      '611' => 'c=r:40,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;',
      'W5' => 'c=r:50,s:6;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0',
      'X6' => 'c=r:70,s:3;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=DC',
      'X7' => 'c=r:50,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;l=OO',
    }.freeze

    GRAY = {
      '51' => 'c=r:50,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:4,b:_0;p=a:5,b:_0',
      '290' => 'c=r:70,s:3;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;l=Z',
      '300' => 'c=r:90;c=r:90;c=r:90;c=r:90;p=a:1,b:_0;p=a:2,b:_0;p=a:1,b:_1;p=a:3,b:_1;p=a:1,b:_2;p=a:4,b:_2;p=a:1,b:_3;p=a:5,b:_3;l=Chi',
      '456' => 'c=r:70,s:5;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0',
      '597' => 'c=r:80,s:3;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;l=B',
      '639' => 'c=r:100,s:4;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0',
      '915' => 'c=r:50,s:3;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0',
      'X8' => 'c=r:100,s:4;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=DC',
      'X9' => 'c=r:70,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;l=OO',
      'X30' => 'c=r:100,s:4;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;l=NY',
    }.freeze

    RED = {}.freeze
    # rubocop:enable Layout/LineLength

    COLORS = %i[white yellow green brown gray red].freeze

    attr_accessor :hex, :legal_rotations, :location_name, :name
    attr_reader :cities, :color, :edges, :junctions, :label,
                :parts, :preprinted, :rotation, :towns, :upgrades, :offboards, :blockers

    def self.for(name, **opts)
      if (code = WHITE[name])
        color = :white
      elsif (code = YELLOW[name])
        color = :yellow
      elsif (code = GREEN[name])
        color = :green
      elsif (code = BROWN[name])
        color = :brown
      elsif (code = GRAY[name])
        color = :gray
      elsif (code = RED[name])
        color = :red
      else
        raise Engine::GameError, "Tile '#{name}' not found"
      end

      from_code(name, color, code, **opts)
    end

    def self.decode(code)
      cache = []

      code.split(';').map do |part_code|
        type, params = part_code.split('=')

        params = params.split(',').map { |param| param.split(':') }.to_h if params.include?(':')

        part(type, params, cache)
      end
    end

    def self.from_code(name, color, code, **opts)
      Tile.new(name, color: color, parts: decode(code), **opts)
    end

    def self.connection_from_code(code, cache)
      case code[0]
      when '_'
        cache[code[1..-1].to_i]
      when 'j'
        Part::Junction.new
      else
        Part::Edge.new(code)
      end
    end

    def self.gauge_from_code(code)
      case code
      when 'n'
        :narrow
      when 'd'
        :dual
      else
        :broad
      end
    end

    def self.part(type, params, cache)
      case type
      when 'p'
        Part::Path.new(Tile.connection_from_code(params['a'], cache),
                       Tile.connection_from_code(params['b'], cache),
                       Tile.gauge_from_code(params.fetch('g', 'b')))
      when 'c'
        city = Part::City.new(params['r'], params.fetch('s', 1))
        cache << city
        city
      when 't'
        town = Part::Town.new(params['r'])
        cache << town
        town
      when 'l'
        label = Part::Label.new(params)
        cache << label
        label
      when 'u'
        upgrade = Part::Upgrade.new(params['c'], params['t']&.split('+'))
        cache << upgrade
        upgrade
      when 'o'
        offboard = Part::Offboard.new(params['r'])
        cache << offboard
        offboard
      end
    end

    # rotation 0-5
    def initialize(name, color:, parts:, rotation: 0, preprinted: false, index: 0, location_name: nil)
      @name = name
      @color = color
      @parts = parts
      @rotation = rotation
      @cities = []
      @paths = []
      @towns = []
      @edges = nil
      @junctions = nil
      @upgrades = []
      @location_name = location_name
      @offboards = []
      @legal_rotations = []
      @blockers = []
      @preprinted = preprinted
      @index = index

      tag_parts
      separate_parts
    end

    def id
      "#{@name}-#{@index}"
    end

    def <=>(other)
      [COLORS.index(@color), @name.to_i] <=> [COLORS.index(other.color), other.name.to_i]
    end

    def rotate!(absolute = nil)
      new_rotation = absolute ||
        @legal_rotations.find { |r| r > @rotation } ||
        @legal_rotations.first ||
        @rotation
      @rotation = new_rotation
      @_paths = nil
      @_exits = nil
    end

    def rotate(num, ticks = 1)
      (num + ticks) % 6
    end

    def paths
      @_paths ||= @paths.map { |path| path.rotate(@rotation) }
    end

    def exits
      @_exits ||= @edges.map { |e| rotate(e.num, @rotation) }.uniq
    end

    def lawson?
      @lawson ||=
        [
          @junctions.any?,
          [cities.size, towns.size] == [1, 0],
          ([cities.size, towns.size] == [0, 1]) && ![1, 2].include?(exits.size),
        ].any?
    end

    def ==(other)
      @name == other.name && @color == other.color && @parts == other.parts
    end

    def upgrade_cost(abilities)
      ignore = abilities.find { |a| a[:type] == :ignore_terrain }

      @upgrades.sum do |upgrade|
        cost = upgrade.cost
        cost = 0 if ignore && upgrade.terrains.uniq == [ignore[:terrain]]
        cost
      end
    end

    def upgrade_tiles(tiles)
      tiles.uniq(&:name).select { |t| upgrades_to?(t) }
    end

    def upgrades_to?(other)
      # correct color progression?
      return false unless COLORS.index(other.color) == (COLORS.index(@color) + 1)

      # correct label?
      return false unless label == other.label

      # honors existing town/city counts?
      # TODO: this is not true for some OO upgrades, or some tiles where
      # double-town can be upgraded into a single town
      return false unless @towns.size == other.towns.size
      return false unless @cities.size == other.cities.size

      # honors pre-existing track?
      return false unless paths_are_subset_of?(other.paths)

      true
    end

    def paths_are_subset_of?(other_paths)
      (0..5).any? do |ticks|
        @paths.all? do |path|
          path = path.rotate(ticks)
          other_paths.any? { |other| path <= other }
        end
      end
    end

    def add_blocker!(private_company)
      @parts << private_company
      @blockers << private_company
    end

    def to_s
      "#{self.class.name} - #{@name}"
    end

    private

    def tag_parts
      @parts.each.group_by(&:class).values.each do |parts|
        parts.each.with_index do |part, index|
          part.index = index
          part.tile = self
        end
      end
    end

    def separate_parts
      @parts.each do |part|
        if part.city?
          @cities << part
        elsif part.label?
          @label = part
        elsif part.path?
          @paths << part
        elsif part.town?
          @towns << part
        elsif part.upgrade?
          @upgrades << part
        elsif part.offboard?
          @offboards << part
        else
          raise "Part #{part} not separated."
        end
      end

      @junctions = @paths.map(&:junction)
      @edges = @paths.flat_map(&:edges)
    end
  end
end
