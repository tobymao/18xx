# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1872
      module Step
        class DraftDistribution < Engine::Step::Base
          attr_reader :companies, :choices

          ACTIONS = %w[bid pass].freeze

          def setup
            @companies = @game.companies.reject(&:owned_by_player?).sort
            entities.each(&:unpass!)
          end

          def available
            @companies
          end

          def pass_description
            'Pass (Buy)'
          end

          def may_purchase?(_company)
            false
          end

          def may_choose?(_company)
            true
          end

          def auctioning; end

          def bids
            {}
          end

          def name
            'Draft Round'
          end

          def description
            'Draft Companies'
          end

          def visible?
            true
          end

          def players_visible?
            true
          end

          def finished?
            @companies.empty? || entities.all?(&:passed?)
          end

          def choose_company(player, company)
            raise GameError, "Cannot buy #{company.name}" unless @companies.include?(company)

            @companies.delete(company)
            company.owner = player
            player.companies << company
            price = company.min_bid
            player.spend(price, @game.bank)
            @game.after_buy_company(player, company, company.value)

            @log << "#{player.name} buys #{company.name} for #{@game.format_currency(price)}"
          end

          def action_finalized
            @round.reset_entity_index! if finished?
          end

          def committed_cash
            0
          end

          def actions(entity)
            return [] if finished?

            entity == current_entity ? ACTIONS : []
          end

          def process_bid(action)
            entities.each(&:unpass!)
            choose_company(action.entity, action.company)
            @round.next_entity_index!
            action_finalized
          end

          def process_pass(action)
            @log << "#{action.entity.name} passes"
            @round.next_entity_index!
            @round.next_entity_index! if current_entity == action.entity
            action.entity.pass!
          end

          def round_state
            {
              companies_pending_par: [],
            }
          end
        end
      end
    end
  end
end
