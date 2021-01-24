# frozen_string_literal: true

require_relative '../helper/type'

module Engine
  module Action
    class Base
      include Helper::Type

      attr_reader :entity
      attr_accessor :id, :user, :created_at, :derived

      def self.from_h(h, game)
        entity = game.get(h['entity_type'], h['entity']) || Player.new(nil, h['entity'])
        obj = new(entity, **h_to_args(h, game))
        obj.user = h['user'] if entity.player && h['user'] != entity.player&.id
        obj.created_at = h['created_at'] || Time.now
        obj.derived = (h['derived'] || []).map { |derived_h| Base.action_from_h(derived_h, game) }
        obj
      end

      def self.action_from_h(h, game)
        Object
        .const_get("Engine::Action::#{Action::Base.type(h['type'])}")
        .from_h(h, game)
      end

      def self.h_to_args(_h, _game)
        {}
      end

      def self.split(klass)
        klass.name.split('::')
      end

      def initialize(entity)
        @entity = entity
        @created_at = Time.now
        @derived = []
      end

      def [](field)
        to_h[field]
      end

      def clear_cache
        @_h = nil
      end

      def to_h
        @_h ||= {
          'type' => type,
          'entity' => entity.id,
          'entity_type' => type_s(entity),
          'id' => @id,
          'user' => @user,
          'created_at' => @created_at.to_i,
          'derived' => @derived.empty? ? nil : @derived.map(&:to_h),
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
