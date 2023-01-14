# frozen_string_literal: true

require_relative '../../../step/exchange'
require_relative 'private_exchange'

module Engine
  module Game
    module G1858
      module Step
        class Exchange < Engine::Step::Exchange
          include PrivateExchange

          def actions(entity)
            if entity.company? || entity.minor?
              ['buy_shares']
            else
              []
            end
          end

          def process_buy_shares(action)
            bundle = action.bundle
            corporation = bundle.corporation
            minor = action.entity
            player = minor.owner

            if !corporation.floated? && !bundle.shares.first.president
              raise GameError, 'Cannot exchange a private railway ' \
                               'for a single share of a public company.'
            end

            acquire_private(corporation, minor)
            if bundle.percent == 40
              exchange_for_presidency(bundle, corporation, minor, player)
              @round.current_actions << action
            else
              exchange_for_share(bundle, corporation, minor, player)
              claim_token(corporation, minor)
              # Need to add an action to the action log, but this can't be a
              # buy shares action as that would end the current player's turn.
              @round.current_actions << Engine::Action::Base.new(minor)
            end
          end

          def exchange_for_presidency(bundle, corporation, company, player)
            raise GameError, "#{corporation.name} cannot be parred" unless @game.can_par?(corporation, player)

            share_price = @game.par_price(company)
            @game.stock_market.set_par(corporation, share_price)
            @round.players_bought[player][corporation] += bundle.percent
            @log << "#{player.name} exchanges #{company.name} and " \
                    "#{@game.format_currency(share_price.price)} for a " \
                    "#{bundle.percent}% share of #{corporation.id}"
            buy_shares(player,
                       bundle,
                       exchange: company,
                       exchange_price: share_price.price,
                       silent: true)
            @game.after_par(corporation)
          end
        end
      end
    end
  end
end
