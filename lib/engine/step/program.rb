# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Program < Base
      ACTIONS = %w[
        program_auction_bid
        program_buy_shares
        program_independent_mines
        program_merger_pass
        program_harzbahn_draft_pass
        program_share_pass
        program_close_pass
        program_disable
      ].freeze

      def actions(entity)
        return [] unless entity.player?

        ACTIONS
      end

      def process_program_auction_bid(action)
        process_program_enable(action)
      end

      def process_program_buy_shares(action)
        raise GameError, 'Until condition is unset' if !@game.loading && !action.until_condition

        process_program_enable(action)
      end

      def process_program_independent_mines(action)
        process_program_enable(action)
      end

      def process_program_merger_pass(action)
        process_program_enable(action)
      end

      def process_program_harzbahn_draft_pass(action)
        process_program_enable(action)
      end

      def process_program_share_pass(action)
        process_program_enable(action)
      end

      def process_program_close_pass(action)
        process_program_enable(action)
      end

      def process_program_enable(action)
        @game.player_log(action.entity, "Enabled programmed action '#{action}'")
        @game.programmed_actions[action.entity] = action
        @round.player_enabled_program(action.entity) if @round.respond_to?(:player_enabled_program)
      end

      def process_program_disable(action)
        program = @game.programmed_actions.delete(action.entity)
        reason = action.reason || 'unknown reason'
        @game.player_log(action.entity, "Disabled programmed action '#{program}' due to '#{reason}'")
      end

      def skip!; end

      def blocks?
        false
      end
    end
  end
end
