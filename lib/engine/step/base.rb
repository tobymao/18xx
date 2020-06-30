# frozen_string_literal: true

module Engine
  module Step
    class Base
      ACTIONS = [].freeze

      def initialize(game, round, deps: nil, **opts)
        @game = game
        @log = game.log
        @round = round
        @deps = deps || []
        @opts = opts
      end

      def description
        raise NotImplementedError
      end

      def pass_description
        'Pass'
      end

      def actions(_entity)
        []
      end

      def current_actions
        current_entity ? actions(current_entity) : []
      end

      def current_entity
        active_entities[0]
      end

      def active_entities
        [entities[index]]
      end

      def round_state
        {}
      end

      def blocking?
        blocks? && current_actions.any?
      end

      def blocks?
        true
      end

      def setup; end

      private

      def entities
        @round.entities
      end

      def index
        @round.index
      end
    end
  end
end
