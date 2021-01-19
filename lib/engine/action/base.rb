# frozen_string_literal: true

require_relative '../helper/type'

module Engine
  module Action
    class Base
      include Helper::Type

      attr_reader :entity
      attr_accessor :id, :user, :created_at, :derived, :round_override, :derived_children

      def self.from_h(h, game)
        entity = game.get(h['entity_type'], h['entity']) || Player.new(nil, h['entity'])
        obj = new(entity, **h_to_args(h, game))
        obj.user = h['user'] if entity.player && h['user'] != entity.player&.id
        obj.created_at = h['created_at'] || Time.now
        obj.derived = h['derived'] || false
        obj.round_override = h['round_override'] || false
        # derived_children is meant to be used as a vehicle for informing the view of derived actions
        #  spawned from this action; derived actions will get their own actions in the game history
        obj.derived_children = []
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
        @derived = false
        @round_override = false
        @created_at = Time.now
        @derived_children = []
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
          'created_at' => @created_at.to_i,
          'derived' => @derived,
          # derived_children is intentionally omitted
          'round_override' => @round_override,
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
