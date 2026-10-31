# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 3.2: a company whose par price was fixed by Investidores Unidos (A) must start at
        # that price.
        class BuySellParShares < Engine::Step::BuySellParShares
          def get_par_prices(entity, corporation)
            fixed = @game.fixed_par_price_for(corporation)
            return [fixed] if fixed

            super
          end

          def process_par(action)
            price = action.share_price
            valid = get_par_prices(action.entity, action.corporation)
            if !price || valid.none? { |p| p.price == price.price && p.coordinates == price.coordinates }
              fixed = @game.fixed_par_price_for(action.corporation)
              if fixed
                raise GameError, "#{action.corporation.name} has its par price fixed at "\
                                 "#{@game.format_currency(fixed.price)} (Private (A))"
              end
              raise GameError, "Invalid par price: #{price ? @game.format_currency(price.price) : 'none'}"
            end

            super
          end
        end
      end
    end
  end
end
