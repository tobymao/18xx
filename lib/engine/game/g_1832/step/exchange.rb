# frozen_string_literal: true

require_relative '../../../step/exchange'

module Engine
  module Game
    module G1832
      module Step
        class Exchange < Engine::Step::Exchange

          def process_buy_shares(action)
            company = action.entity
            bundle = action.bundle
            raise GameError, "Cannot exchange #{action.entity.id} for #{bundle.corporation.id}" unless can_exchange?(company,
                                                                                                                     bundle)

            buy_shares(company.owner, bundle, exchange: company)
            @round.players_history[company.owner][bundle.corporation] << action if @round.respond_to?(:players_history)
            @game.assign_london_corporation(bundle.corporation)
            ability.use!
            @round.current_actions << action
            company.close!
          end
        end
      end
    end
  end
end
