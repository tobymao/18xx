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

           buy_shares(company.owner, bundle, exchange: company)
            @round.players_history[company.owner][bundle.corporation] << action if @round.respond_to?(:players_history)
            @game.london_corporation = bundle.corporation
            ability.use!
            @round.current_actions << action
          end
        end
      end
    end
  end
end
