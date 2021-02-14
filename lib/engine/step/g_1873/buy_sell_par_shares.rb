# frozen_string_literal: true

require_relative '../base'
require_relative '../share_buying'
require_relative '../../action/buy_shares'
require_relative '../../action/par'

module Engine
  module Step
    module G1873
      class BuySellParShares < BuySellParShares
        def description
          'Sell then Buy Certificates or Form Public Mine'
        end

        def purchasable_companies(_entity)
          []
        end

        # FIXME: need to deal with receivership first and second buy
        def can_buy_multiple?(_entity, corporation)
          return false unless @game.railway?(corporation)

          @current_actions.any? { |x| x.is_a?(Action::Par) && x.corporation == corporation} &&
            @current_actions.none? { |x| x.is_a?(Action::BuyShares) }
        end

        def ipo_type(entity)
          if @game.railway?(entity)
            :par
          else
            :form
          end
        end

        def get_par_prices(entity, corp)
          super if @game.railway?(corp)

          @game
            .stock_market
            .par_prices
        end

        def process_par(action)
          corporation = action.corporation
          entity = action.entity
          
          return super if @game.railway?(corporation)

          form_public_mine(entity, corporation)

          @round.last_to_act = entity
          @current_actions << action
        end

        def form_public_mine(entity, corporation)
          corporation.owner = entity
          @round.pending_forms << { corporation: corporation, owner: entity, targets: [] }
          @log << "Public Mining Company #{corporation.name} forms"
        end
      end
    end
  end
end
