# frozen_string_literal: true

require_relative '../../../step/exchange'

module Engine
  module Game
    module G21Moon
      module Step
        class Exchange < Engine::Step::Exchange
          def can_exchange?(entity, bundle = nil)
            return false unless @game.turn > 1

            super
          end

          # ignore the 50% limit
          def can_gain?(entity, bundle, exchange: false)
            return if !bundle || !entity
            return if bundle.owner&.player?

            exchange || @game.num_certs(entity) < @game.cert_limit
          end

          def process_buy_shares(action)
            company = action.entity
            bundle = action.bundle
            raise GameError, "Cannot exchange #{action.entity.id} for #{bundle.corporation.id}" unless can_exchange?(company,
                                                                                                                     bundle)

            @log << "#{company.name} exchanged for share of #{bundle.corporation.name} and closes"
            buy_shares(company.owner, bundle, exchange: :free)
            @round.players_history[company.owner][bundle.corporation] << action if @round.respond_to?(:players_history)

            @game.abilities(company, :exchange).use!
            company.close!
          end
        end
      end
    end
  end
end
