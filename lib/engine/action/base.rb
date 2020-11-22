# frozen_string_literal: true

require_relative '../helper/type'

module Engine
  module Action
    class Base
      include Helper::Type

      attr_reader :entity
      attr_accessor :id, :user

      def self.from_h(h, game)
        entity = game.get(h['entity_type'], h['entity']) || Player.new(nil, h['entity'])
        obj = new(entity, **h_to_args(h, game))
        obj.user = h['user'] if entity.player && h['user'] != entity.player&.name
        obj
      end

      def self.h_to_args(_h, _game)
        {}
      end

      def self.split(klass)
        klass.name.split('::')
      end

      def initialize(entity)
        @entity = entity
      end

      def [](field)
        to_h[field]
      end

      def to_h
        @_h ||= {
          'type' => type,
          'entity' => entity.id,
          'entity_type' => type_s(entity),
          'id' => @id,
          'user' => @user,
          **args_to_h,
        }.reject { |_, v| v.nil? }
      end

      def args_to_h
        {}
      end

      def pass?
        false
      end

      def copy(game)
        self.class.from_h(to_h, game)
      end

      def free?
        false
      end
    end
  end
end
