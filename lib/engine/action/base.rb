# frozen_string_literal: true

require_relative '../helper/type'

module Engine
  module Action
    class Base
      include Helper::Type

      attr_reader :entity
      attr_accessor :id, :user, :created_at, :auto_actions

      def self.from_h(h, game)
        entity = game.get(h['entity_type'], h['entity']) || Player.new(nil, h['entity'])
        obj = new(entity, **h_to_args(h, game))
        obj.user = h['user'] if entity.player && h['user'] != entity.player&.id
        obj.created_at = h['created_at'] || Time.now
        obj.auto_actions = (h['auto_actions'] || []).map { |auto_h| Base.action_from_h(auto_h, game) }
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
        @auto_actions = []
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
          'auto_actions' => @auto_actions.empty? ? nil : @auto_actions.map(&:to_h),
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
