# frozen_string_literal: true

require 'engine/city'
require 'engine/edge'
require 'engine/path'

module Engine
  class Tile
    YELLOW = {
      '5' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:1',
      '6' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:2',
      '7' => 'p=a:0,b:1',
      '8' => 'p=a:0,b:2',
      '9' => 'p=a:0,b:3',
      '57' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:3',
    }.freeze

    GREEN = {
      '18' => 'p=a:0,b:3;p=a:1,b:2',
    }.freeze

    attr_reader :color, :name, :parts, :rotation

    def self.for(name, **opts)
      if (code = YELLOW[name])
        color = :yellow
      elsif (code = GREEN[name])
        color = :green
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
          else
            [k, Edge.new(v)]
          end
        end.to_h

        Path.new(params['a'], params['b'])
      when 'c'
        city = City.new(params['r'])
        cache << city
        city
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
