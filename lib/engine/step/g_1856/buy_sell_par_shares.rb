# frozen_string_literal: true

require_relative '../buy_sell_par_shares'

module Engine
  module Step
    module G1856
      class BuySellParShares < BuySellParShares
        def can_buy?(entity, bundle)
          super && !attempt_cgr_action_while_not_floated?(bundle)
        end

        def can_sell?(entity, bundle)
          super && !attempt_cgr_action_while_not_floated?(bundle) && vested?(entity, bundle)
        end

        def can_gain?(entity, bundle)
          super && !attempt_cgr_action_while_not_floated?(bundle)
        end

        def attempt_cgr_action_while_not_floated?(bundle)
          bundle.corporation == @game.national && !bundle.corporation.floated?
        end

        def vested?(player, bundle)
          # If the player will be left with at least 1 share, or is fully vested, this is fair game
          return true unless @round.players_unvested_holdings[player] == bundle.corporation

          # The player has an unvested share, will they be left with at least 1 share?
          bundle.num_shares < player.num_shares_of(bundle.corporation)
        end

        def process_buy_shares(action)
          super
          @round.players_unvested_holdings[action.entity] = action.bundle.corporation
        end

        def process_par(action)
          share_price = action.share_price
          corporation = action.corporation
          entity = action.entity
          raise GameError, "#{corporation} cannot be parred" unless @game.can_par?(corporation, entity)

          corporation.par!
          @log << "#{corporation.name} is parred as a #{corporation.capitalization_type_desc} cap corporation"
          @game.stock_market.set_par(corporation, share_price)
          share = corporation.shares.first
          buy_shares(entity, share.to_bundle)
          @game.after_par(corporation)
          @round.last_to_act = entity
          @current_actions << action
        end
      end
    end
  end
end
