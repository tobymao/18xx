# frozen_string_literal: true

require 'engine/game_error'

module Engine
  module Round
    class Base
      attr_reader :entities, :current_entity

      def initialize(entities, log:, **_kwargs)
        @entities = entities
        @log = log
        @current_entity = @entities.first
      end

      def description
        raise NotImplementedError
      end

      def current_player
        @current_entity.player
      end

      def active_entities
        [@current_entity]
      end

      def next_entity
        index = @entities.find_index(@current_entity) + 1
        index < @entities.size ? @entities[index] : @entities[0]
      end

      def pass(entity)
        entity.pass!
      end

      def process_action(action)
        entity = action.entity
        raise GameError, "It is not #{entity.name}'s turn" unless can_act?(entity)

        if action.pass?
          @log << "#{entity.name} passes"
          pass(entity)
        else
          @current_entity.unpass!
          _process_action(action)
        end
        @current_entity = next_entity
      end

      def finished?
        @entities.all?(&:passed?)
      end

      def can_act?(entity)
        active_entities.include?(entity)
      end

      def auction?
        false
      end

      def stock?
        false
      end

      def operating?
        false
      end

      private

      def _process(_action)
        raise NotImplementedError
      end
    end
  end
end
