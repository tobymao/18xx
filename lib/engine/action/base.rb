# frozen_string_literal: true

module Engine
  module Action
    class Base
      attr_reader :entity

      def self.from_h(h, game)
        new(game.send("#{h['entity_type']}_by_id"), *args(h, game))
      end

      def self.h_to_args(_h, _game)
        []
      end

      def initialize(entity)
        @entity = entity
      end

      def to_h
        {
          'entity' => entity.id,
          'entity_type' => entity.class,
          **args
        }
      end

      def args_to_h
        {}
      end

      def pass?
        false
      end
    end
  end
end
