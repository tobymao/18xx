# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18ZOO
      module Step
        class SimpleDraft < Engine::Step::Base
          ACTIONS_WITH_PASS = %w[bid pass].freeze

          def setup
            @finished = false
          end

          def actions(entity)
            return [] if finished?

            entity == current_entity ? ACTIONS_WITH_PASS : []
          end

          def available
            @game.available_companies.sort + @game.future_companies
          end

          def may_purchase?(company)
            @game.available_companies.include?(company)
          end

          def auctioning; end

          def auctioneer?
            true
          end

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

          def max_bid(_entity, company)
            may_purchase?(company) ? min_bid(company) : 0
          end

          def process_bid(action)
            company = action.company
            player = action.entity
            price = action.price

            company.owner = player
            player.companies << company
            player.spend(price, @game.bank)

            @game.available_companies.delete(company)

            @log << "#{player.name} buys \"#{company.name}\" for #{@game.format_currency(price)}"

            @game.apply_custom_ability(company)

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
end
