# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class SimpleDraft < Base
      attr_reader :companies, :choices

      ACTIONS = %w[bid].freeze

      def setup
        @companies = @game.companies.sort
      end

      def available
        @companies
      end

      def may_purchase?(_company)
        true
      end

      def may_choose?(_company)
        true
      end

      def auctioning; end

      def bids
        {}
      end

      def visible?
        true
      end

      def players_visible?
        true
      end

      def name
        'Draft'
      end

      def description
        'Draft One Company Each'
      end

      def finished?
        @game.players.all? { |p| p.companies.any? }
      end

      def actions(entity)
        return [] if finished?

        entity == current_entity ? ACTIONS : []
      end

      def process_bid(action)
        company = action.company
        player = action.entity
        price = action.price

        company.owner = player
        player.companies << company
        player.spend(price, @game.bank)

        @companies.delete(company)

        @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

        @round.next_entity_index!
        action_finalized
      end

      def action_finalized
        return unless finished?

        @companies.each do |c|
          @log << "#{c.name} is removed from the game"
          @game.companies.delete(c)
        end
        @round.reset_entity_index!
      end

      def committed_cash(_player, _show_hidden = false)
        0
      end

      def min_bid(company)
        return unless company

        company.value
      end
    end
  end
end
