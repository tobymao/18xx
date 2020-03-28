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

      def pass(action)
        action.entity.pass!
      end

      def process_action(action)
        entity = action.entity
        raise GameError, "It is not #{entity.name}'s turn" unless can_act?(entity)

        if action.pass?
          @log << "#{entity.name} passes"
          pass(action)
          pass_processed(action)
        else
          @current_entity.unpass!
          _process_action(action)
          action_processed(action)
        end
        change_entity(action)
        action_finalized(action)
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

      def log_share_price(entity, from)
        @log << "#{entity.name}'s share price changes from $#{from} to $#{entity.share_price.price} "
      end

      # methods to override
      def _process(_action)
        raise NotImplementedError
      end

      def change_entity(_action)
        @current_entity = next_entity
      end

      def pass_processed(_action); end

      def action_processed(_action); end

      def action_finalized(_action); end
    end
  end
end
