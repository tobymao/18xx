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
        new(entity, **h_to_args(h, game))
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
        {
          'type' => type,
          'entity' => entity.id,
          'entity_type' => type_s(entity),
          'id' => @id,
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

      def type
        type_s(self)
      end

      private

      def type_s(obj)
        self.class.split(obj.class).last.gsub(/(.)([A-Z])/, '\1_\2').downcase
      end
    end
  end
end
