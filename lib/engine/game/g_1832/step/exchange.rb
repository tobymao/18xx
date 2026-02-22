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
            unless (ability = @game.abilities(company, :exchange))
              raise GameError,
                    "Could not assign #{company.name} to #{target.name}; :exchange ability not found"
            end
            raise GameError, "Cannot exchange #{action.entity.id} for #{bundle.corporation.id}" unless can_exchange?(company,
                                                                                                                     bundle)

            buy_shares(company.owner, bundle, exchange: company)
            @round.players_history[company.owner][bundle.corporation] << action if @round.respond_to?(:players_history)
            if company.name == 'London Investment'
              @game.assign_london_company(bundle.corporation)
              ability.use!
              @round.current_actions << action
            end
            company.close! if company.name != 'London Investment'
          end
        end
      end
    end
  end
end
