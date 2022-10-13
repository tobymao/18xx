# frozen_string_literal: true

require_relative '../../../step/exchange'

module Engine
  module Game
    module G1858
      module Step
        class Exchange < Engine::Step::Exchange
          def actions(entity)
            if entity.minor?
              ['buy_shares']
            else
              []
            end
          end

          def process_buy_shares(action)
            bundle = action.bundle
            corporation = bundle.corporation
            company = action.entity
            player = company.owner

            unless @game.company_corporation_connected?(company, corporation)
              raise GameError, "#{action.entity.name} is not connected to #{corporation.full_name}"
            end

            acquire_company(corporation, company)
            buy_shares(player, bundle, exchange: :free)

            # Need to add an action to the action log, but this can't be a
            # buy shares action as that would end the current player's turn.
            @round.current_actions << Engine::Action::Base.new(company)
          end

          def acquire_company(corporation, company)
            player = company.owner
            player.companies.delete(company)
            @game.minors.delete(company)
            company.owner = corporation
            corporation.companies << company
            # TODO: offer option to place a token
            @log << "#{corporation.name} acquires #{company.name} from #{player.name}"
          end
        end
      end
    end
  end
end
