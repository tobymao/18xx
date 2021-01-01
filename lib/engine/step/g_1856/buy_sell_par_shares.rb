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
          super && !attempt_cgr_action_while_not_floated?(bundle)
        end

        def can_gain?(entity, bundle)
          super && !attempt_cgr_action_while_not_floated?(bundle)
        end

        def attempt_cgr_action_while_not_floated?(bundle)
          bundle.corporation == @game.national && !bundle.corporation.floated?
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
