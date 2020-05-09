# frozen_string_literal: true

module Engine
  module Action
    class Base
      attr_reader :entity
      attr_accessor :id

      def self.type(type)
        type.split('_').map(&:capitalize).join
      end

      def self.from_h(h, game)
        entity = game.send("#{h['entity_type']}_by_id", h['entity'])
        new(entity, *h_to_args(h, game))
      end

      def self.h_to_args(_h, _game)
        []
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
        {
          'type' => self.class.type_s(self.class),
          'entity' => entity.id,
          'entity_type' => self.class.type_s(entity.class),
          'id' => @id,
          **args_to_h,
        }
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

      # Does an undo/redo not apply to this action?
      def self.keep_on_undo?
        false
      end

      def self.type_s(klass)
        split(klass).last.gsub(/(.)([A-Z])/, '\1_\2').downcase
      end
    end
  end
end
