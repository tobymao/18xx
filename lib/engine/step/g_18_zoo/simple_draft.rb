# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18ZOO
      class SimpleDraft < Base
        ACTIONS_WITH_PASS = %w[bid pass].freeze

        def setup
          @companies = @game.companies_for_isr.sort
          @bank_companies = @game.bank_corporation.companies
          @finished = false
        end

        def actions(entity)
          return [] if finished?

          entity == current_entity ? ACTIONS_WITH_PASS : []
        end

        def available
          @companies
        end

        def may_purchase?(_company)
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
          'Draft Powers'
        end

        def pass_description
          'Pass (Buy)'
        end

        def finished?
          @finished
        end

        def min_bid(company)
          company&.value
        end

        def process_bid(action)
          company = action.company
          player = action.entity
          price = action.price

          company.owner = player
          player.companies << company
          player.spend(price, @game.bank)

          @companies.delete(company)
          @bank_companies.delete(@bank_companies.select { |c| c.sym == company.sym }.first)

          @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

          action_finalized
        end

        def process_pass(action)
          @log << "#{action.entity.name} passes"

          action_finalized
        end

        def committed_cash(_player, _show_hidden = false)
          0
        end

        private

        def action_finalized
          @round.next_entity_index!
          @finished = true if @round.entity_index.zero?

          @round.reset_entity_index! if finished?
        end
      end
    end
  end
end
