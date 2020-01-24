# frozen_string_literal: true

require 'engine/game_error'
require 'engine/part/city'
require 'engine/part/town'
require 'engine/part/edge'
require 'engine/part/junction'
require 'engine/part/label'
require 'engine/part/path'

module Engine
  class Tile
    YELLOW = {
      '1' => 't=r:10,n:_A;p=a:0,b:_0;p=a:_0,b:2;t=r:10,n:_B;p=a:3,b:_1;p=a:_1,b:5',
      '3' => 't=r:10;p=a:0,b:_0;p=a:_0,b:5',
      '4' => 't=r:10;p=a:0,b:_0;p=a:_0,b:3',
      '5' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:1',
      '6' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:2',
      '7' => 'p=a:0,b:1',
      '8' => 'p=a:0,b:2',
      '9' => 'p=a:0,b:3',
      '57' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:3',
      '58' => 't=r:10;p=a:0,b:_0;p=a:_0,b:4',
      '437' => 't=r:30,n:Port;p=a:0,b:_0;p=a:_0,b:2',
      '438' => 'c=r:40,n:Kotohira;p=a:0,b:_0;p=a:_0,b:2;l=H', # u: 80 JPY
      '1889;C4' => 'c=r:20,n:Ohzu;p=a:2,b:_0',
      '1889;K4' => 'c=r:30,n:Takamatsu;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;l=T', # v:KO
    }.freeze

    GREEN = {
      '12' => 'c=r:30;p=a:0,b:_0;p=a:1,b:_0;p=a:5,b:_0',
      '13' => 'c=r:30;p=a:0,b:_0;p=a:2,b:_0;p=a:4,b:_0',
      '14' => 'c=r:30,s:2;p=a:0,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:5,b:_0',
      '15' => 'c=r:30,s:2;p=a:0,b:_0;p=a:4,b:_0;p=a:3,b:_0;p=a:5,b:_0',
      '16' => 'p=a:0,b:4;p=a:5,b:3',
      '18' => 'p=a:0,b:3;p=a:1,b:2',
      '19' => 'p=a:5,b:1;p=a:0,b:3',
      '20' => 'p=a:0,b:3;p=a:5,b:2',
      '23' => 'p=a:0,b:3;p=a:0,b:4',
      '24' => 'p=a:0,b:3;p=a:0,b:2',
      '25' => 'p=a:0,b:2;p=a:0,b:4',
      '26' => 'p=a:0,b:3;p=a:0,b:5',
      '27' => 'p=a:0,b:3;p=a:3,b:4',
      '28' => 'p=a:0,b:4;p=a:0,b:5',
      '29' => 'p=a:0,b:4;p=a:5,b:4',
      '81A' => 'p=a:0,b:j;p=a:2,b:j;p=a:4,b:j',
      '205' => 'c=r:30;p=a:0,b:_0;p=a:3,b:_0;p=a:4,b:_0',
      '206' => 'c=r:30;p=a:0,b:_0;p=a:3,b:_0;p=a:5,b:_0',
      '298' => 'c=r:40,n:_A;c=r:40,n:_B;c=r:40,n:_C;c=r:40,n:_D;l=Chi;'\
               'p=a:1,b:_0;p=a:0,b:_1;p=a:5,b:_2;p=a:4,b:_3;'\
               'p=a:_0,b:3;p=a:_2,b:3;p=a:_3,b:3;p=a:_1,b:3',
      '439' => 'c=r:60,s:2,n:Kotohira;p=a:0,b:_0;p=a:2,b:_0;p=a:4,b:_0;l=H', # u: 80 JPY
      '440' => 'c=r:40,n:Takamatsu,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:5,b:_0;l=T',
      '1889;F9' => 'c=r:30,s:2,n:Kouchi;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=K', # v:TR
    }.freeze

    BROWN = {
      '39' => 'p=a:1,b:5;p=a:0,b:1;p=a:5,b:0',
      '40' => 'p=a:0,b:2;p=a:2,b:4;p=a:4,b:0',
      '41' => 'p=a:0,b:3;p=a:3,b:4;p=a:4,b:0',
      '42' => 'p=a:0,b:3;p=a:3,b:2;p=a:2,b:0',

      '45' => 'p=a:3,b:1;p=a:1,b:5;p=a:0,b:3;p=a:5,b:0',
      '46' => 'p=a:1,b:5;p=a:3,b:5;p=a:0,b:3;p=a:1,b:0',

      '47' => 'p=a:0,b:3;p=a:3,b:5;p=a:5,b:2;p=a:2,b:0',

      '448' => 'c=r:40,s:2;p=a:0,b:_0;p=a:4,b:_0;p=a:3,b:_0;p=a:5,b:_0',

      '465' => 'c=r:40,s:2,n:Kouchi;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=K', # v:TR

      '466' => 'c=r:60,n:Takamatsu,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:5,b:_0;l=T',

      '492' => 'c=r:80,s:3,n:Kotohira;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0;l=H',

      '611' => 'c=r:40,s:2;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;',

      'W5' => 'c=r:50,s:6;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0',
    }.freeze

    GRAY = {
      '456' => 'c=r:70,s:5;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0',
      '639' => 'c=r:100,s:4;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0',
      '1889;B3' => 't=r:20;p=a:0,b:_0;p=a:_0,b:5',
      '1889;B7' => 'c=r:40,s:2,n:Uwajima;p=a:1,b:_0;p=a:3,b:_0;p=a:5,b:_0', # v:UR
      '1889;J7' => 'p=a:1,b:5',
    }.freeze

    attr_reader :color, :name, :parts, :rotation

    def self.for(name, **opts)
      if (code = YELLOW[name])
        color = :yellow
      elsif (code = GREEN[name])
        color = :green
      elsif (code = BROWN[name])
        color = :brown
      elsif (code = GRAY[name])
        color = :gray
      else
        raise Engine::GameError, "Tile '#{name}' not found"
      end

      Tile.new(name, color: color, parts: decode(code), **opts)
    end

    def self.decode(code)
      cache = []

      code.split(';').map do |part_code|
        type, params = part_code.split('=')

        params = params.split(',').map { |param| param.split(':') }.to_h if params.include?(':')

        part(type, params, cache)
      end
    end

    def self.part(type, params, cache)
      case type
      when 'p'
        params = params.map do |k, v|
          case v[0]
          when '_'
            [k, cache[v[1..-1].to_i]]
          when 'j'
            [k, Part::Junction.new]
          else
            [k, Part::Edge.new(v)]
          end
        end.to_h

        Part::Path.new(params['a'], params['b'])
      when 'c'
        city = Part::City.new(params['r'], params.fetch('s', 1), params['n'])
        cache << city
        city
      when 't'
        town = Part::Town.new(params['r'], params['n'])
        cache << town
        town
      when 'l'
        label = Part::Label.new(params)
        cache << label
        label
      end
    end

    # rotation 0-5
    def initialize(name, color:, parts:, rotation: 0)
      @name = name
      @color = color
      @parts = parts
      @rotation = rotation
    end

    def cities
      @cities ||= @parts.select(&:city?)
    end

    def towns
      @towns ||= @parts.select(&:town?)
    end

    def paths
      @paths ||= @parts.select(&:path?)
    end

    def connections
      @connections ||= paths.flat_map { |p| [p.a, p.b] }
    end

    def label
      @label ||= @parts.find(&:label?)
    end

    def lawson?
      @lawson ||= connections.any?(&:junction?)
    end

    def rotate!(clockwise = true)
      direction = clockwise ? 1 : -1
      @rotation += direction
      @rotation = @rotation % 6
    end

    def ==(other)
      @name == other.name && @color == other.color && @parts == other.parts
    end
  end
end
