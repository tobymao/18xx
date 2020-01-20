# frozen_string_literal: true

require 'engine/city'
require 'engine/town'
require 'engine/edge'
require 'engine/game_error'
require 'engine/junction'
require 'engine/path'

module Engine
  class Tile
    YELLOW = {
      '1' => 't=r:10,n:A;p=a:0,b:_0;p=a:_0,b:2;t=r:10,n:B;p=a:3,b:_1;p=a:_1,b:5',
      '3' => 't=r:10;p=a:0,b:_0;p=a:_0,b:5',
      '4' => 't=r:10;p=a:0,b:_0;p=a:_0,b:3',
      '5' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:1',
      '6' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:2',
      '7' => 'p=a:0,b:1',
      '8' => 'p=a:0,b:2',
      '9' => 'p=a:0,b:3',
      '57' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:3',
      '58' => 't=r:10;p=a:0,b:_0;p=a:_0,b:4',
      '437' => 't=r:30;p=a:0,b:_0;p=a:_0,b:2', # 1889 Port
      '438' => 'c=r:40;p=a:0,b:_0;p=a:_0,b:2', # 1889 Kotohira
      '1889;C4' => 'c=r:20;p=a:2,b:_0',
      '1889;K4' => 'c=r:30;p=a:0,b:_0;p=a:1,b:_0;p=a:2,b:_0', # v:KO
    }.freeze

    GREEN = {
      '12' => 'c=r:30;p=a:0,b:_0;p=a:1,b:_0;p=a:5,b:_0',
      '13' => 'c=r:30;p=a:0,b:_0;p=a:2,b:_0;p=a:4,b:_0',
      '14' => 'c=r:30;p=a:0,b:_0;p=a:2,b:_0;p=a:3,b:_0;p=a:5,b:_0', # s:2
      '16' => 'p=a:0,b:4;p=a:5,b:3',
      '18' => 'p=a:0,b:3;p=a:1,b:2',
      '81A' => 'p=a:0,b:j;p=a:2,b:j;p=a:4,b:j',
      '1889;F9' => 'c=r:30;p=a:2,b:_0;p=a:3,b:_0;p=a:4,b:_0;p=a:5,b:_0', # s:2,v:TR
    }.freeze

    GRAY = {
      '1889;B3' => 't=r:20;p=a:0,b:_0;p=a:_0,b:5',
      '1889;B7' => 'c=r:40;p=a:1,b:_0;p=a:3,b:_0;p=a:5,b:_0', # v:UR
      '1889;G14' => 't=r:20;p=a:3,b:_0;p=a:_0,b:4',
      '1889;J7' => 'p=a:1,b:5',
    }.freeze

    attr_reader :color, :name, :parts, :rotation

    def self.for(name, **opts)
      if (code = YELLOW[name])
        color = :yellow
      elsif (code = GREEN[name])
        color = :green
      elsif (code = GRAY[name])
        color = :gray
      else
        raise Engine::GameError, "Tile '#{name}' not found"
      end

      Tile.new(name, color: color, parts: decode(code), **opts)
    end

    def self.decode(code)
      cache = []

      code.split(';').map do |path_code|
        type, params = path_code.split('=')
        params = params.split(',').map { |param| param.split(':') }.to_h
        path(type, params, cache)
      end
    end

    def self.path(type, params, cache)
      case type
      when 'p'
        params = params.map do |k, v|
          case v[0]
          when '_'
            [k, cache[v[1..-1].to_i]]
          when 'j'
            [k, Junction.new]
          else
            [k, Edge.new(v)]
          end
        end.to_h

        Path.new(params['a'], params['b'])
      when 'c'
        city = City.new(params['r'])
        cache << city
        city
      when 't'
        town = Town.new(params['r'], params['n'])
        cache << town
        town
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
      @cities ||= @parts.select { |p| p.is_a?(City) }
    end

    def towns
      @towns ||= @parts.select { |p| p.is_a?(Town) }
    end

    def paths
      @paths ||= @parts.select { |p| p.is_a?(Path) }
    end

    def rotate!(clockwise)
      direction = clockwise ? 1 : -1
      @rotation += direction
      @rotation = @rotation % 6
    end

    def ==(other)
      @name == other.name && @color == other.color && @parts == other.parts
    end
  end
end
