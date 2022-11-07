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

            acquire_company(corporation, company)
            if bundle.percent == 40
              exchange_for_presidency(bundle, corporation, company, player)
              @round.current_actions << action
            else
              exchange_for_share(bundle, corporation, company, player)
              # Need to add an action to the action log, but this can't be a
              # buy shares action as that would end the current player's turn.
              @round.current_actions << Engine::Action::Base.new(company)
            end
          end

          def exchange_for_presidency(bundle, corporation, company, player)
            raise GameError, "#{corporation.name} cannot be parred" unless @game.can_par?(corporation, player)

            share_price = company.par_price(@game.stock_market)
            @game.stock_market.set_par(corporation, share_price)
            @round.players_bought[player][corporation] += bundle.percent
            buy_shares(player, bundle, exchange: company, exchange_price: share_price.price)
            @game.after_par(corporation)
          end

          def exchange_for_share(bundle, corporation, company, player)
            unless @game.company_corporation_connected?(company, corporation)
              raise GameError, "#{company.name} is not connected to #{corporation.full_name}"
            end

            buy_shares(player, bundle, exchange: :free)
            cities = @game.reserved_cities(corporation, company)
            return if cities.empty?

            @round.pending_tokens << {
              entity: corporation,
              hexes: cities.map(&:hex),
              token: corporation.next_token,
            }
          end

          def acquire_company(corporation, company)
            player = company.owner
            player.companies.delete(company)
            @game.minors.delete(company)
            company.owner = corporation
            corporation.companies << company
            @log << "#{corporation.name} acquires #{company.name} from #{player.name}"
          end
        end
      end
    end
  end
end
