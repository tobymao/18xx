# frozen_string_literal: true

require_relative 'base'

module Engine
  module Round
    class Merger < Base
      def name
        self.class.round_name
      end

      def self.round_name
        raise NotImplementedError
      end

      def merger?
        true
      end

      def use_operating_round_view?(current_entity_actions)
        return false unless @game.train_actions_always_use_operating_round_view?

        (%w[buy_train scrap_train reassign_trains] & current_entity_actions).any?
      end
    end
  end
end
