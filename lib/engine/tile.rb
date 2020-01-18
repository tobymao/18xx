# frozen_string_literal: true
#
require 'engine/city'
require 'engine/edge'
require 'engine/path'

module Engine
  class Tile
    YELLOW = {
      '8' => 'p=a:0,b:3',
      '9' => 'p=a:0,b:2',
      '57' => 'c=r:20;p=a:0,b:_0;p=a:_0,b:3',
    }

    GREEN = {
      '18' => 'e=a:0,b:3;e=a:1,b:2',
    }

    attr_reader :color, :name, :parts

    def self.from(name)
      if code = YELLOW[name]
        color = :yellow
      elsif code = GREEN[name]
        color = :green
      end

      Tile.new(name, color: color, parts: decode(code))
    end

    def self.decode(code)
      cache = []

      paths = code.split(';').map do |path_code|
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

    def initialize(name, color:, parts:)
      @name = name
      @color = color
      @parts = parts
    end

    def ==(other)
      @name == other.name && @color == other.color && @parts == other.parts
    end
  end
end
