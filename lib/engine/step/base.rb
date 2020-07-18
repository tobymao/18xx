# frozen_string_literal: true

require_relative '../passer'

module Engine
  module Step
    class Base
      include Passer

      ACTIONS = [].freeze

      def initialize(game, round, **opts)
        @game = game
        @log = game.log
        @round = round
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

      def available_hex(hex); end

      def log_pass(entity)
        @log << "#{entity.name} passes #{description.downcase}"
      end

      def log_skip(entity)
        @log << "#{entity.name} skips #{description.downcase}"
      end

      def process_pass(action)
        log_pass(action.entity)
        pass!
      end

      def skip!
        log_skip(current_entity)
        pass!
      end

      def current_actions
        current_entity ? actions(current_entity) : []
      end

      def current_entity
        active_entities[0]
      end

      def active_entities
        [entities[entity_index]]
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

      def sequential?
        false
      end

      def setup; end

      private

      def entities
        @round.entities
      end

      def entity_index
        @round.entity_index
      end

      # The following should be removed when specials are moved to steps
      def can_gain?; end
    end
  end
end
