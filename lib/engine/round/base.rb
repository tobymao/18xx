# frozen_string_literal: true

require 'engine/game_error'

module Engine
  module Round
    class Base
      attr_reader :entities, :current_entity, :current_entities, :active_entities

      def initialize(entities, **opts)
        @entities = entities
        @active_entities = [@entities.first]
        @current_entity = @active_entities.first
        init_round(opts)
      end

      def current_player
        @current_entity.player
      end

      def next_entity
        index = @entities.find_index(@current_entity) + 1
        index < @entities.size ? @entities[index] : @entities[0]
      end

      def pass(_entity)
        raise NotImplementedError
      end

      def process_action(action)
        entity = action.entity
        raise GameError, "It is not {action.entity.name}'s turn" unless can_act?(entity)

        if action.pass?
          pass(entity)
        else
          _process_action(action)
        end

        @current_entity = next_entity
      end

      def finished?
        true
      end

      def can_act?(entity)
        active_entities.include?(entity)
      end

      private

      def _process(_action)
        raise NotImplementedError
      end

      def init_round(opts); end
    end
  end
end
