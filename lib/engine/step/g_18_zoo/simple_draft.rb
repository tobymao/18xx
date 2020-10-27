# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18ZOO
      class SimpleDraft < Base
        attr_reader :companies

        ACTIONS_WITH_PASS = %w[bid pass].freeze

        def setup
          @companies = @game.companies.select { |company| company.phase == 'ISR' }.sort
          @finished = false
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

        def finished?
          @finished
        end

        def actions(entity)
          return [] if finished?

          entity == current_entity ? ACTIONS_WITH_PASS : []
        end

        def process_bid(action)
          @log << "CHECK if finished: #{@finished} - #{@round.entity_index} #{@game.players.size}"

          company = action.company
          player = action.entity
          price = action.price

          company.owner = player
          player.companies << company
          player.spend(price, @game.bank)

          @companies.delete(company)

          @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"

          action_finalized
        end

        def process_pass(action)
          @log << "CHECK if finished: #{@finished} - #{@round.entity_index} #{@game.players.size}"

          @log << "#{action.entity.name} passes"

          action_finalized
        end

        def action_finalized
          @round.next_entity_index!
          @finished = true if @round.entity_index.zero?

          return unless finished?

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
end
