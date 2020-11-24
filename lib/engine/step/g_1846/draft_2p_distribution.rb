# frozen_string_literal: true

require_relative 'draft_distribution'

module Engine
  module Step
    module G1846
      class Draft2pDistribution < DraftDistribution
        def setup
          @companies = @game.companies.reject(&:owned_by_player?).sort
          entities.each(&:unpass!)
        end

        def available
          @companies
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

        def actions(entity)
          return [] if finished?

          actions = @game.companies.none?(&:owned_by_player?) ? ACTIONS : ACTIONS_WITH_PASS

          entity == current_entity ? actions : []
        end

        def process_pass(action)
          return super if only_one_company?
          raise @game.game_error 'Cannot pass on first turn' if @game.companies.none?(&:owned_by_player?)

          @log.action! 'passes'
          @round.next_entity_index!
          action.entity.pass!
        end

        def process_bid(action)
          action.entity.unpass!
          super
        end

        def choose_company(player, company)
          raise @game.game_error "Cannot buy #{company.name}" unless @companies.include?(company)

          @companies.delete(company)
          company.owner = player
          player.companies << company
          price = company.min_bid
          player.spend(price, @game.bank) if price.positive?

          float_minor(company)

          @log.action! "buys #{company.name} for #{@game.format_currency(price)}"
        end

        def action_finalized
          @round.reset_entity_index! if finished?
        end

        def committed_cash
          0
        end
      end
    end
  end
end
