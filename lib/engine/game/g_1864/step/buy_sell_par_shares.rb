# frozen_string_literal: true

require_relative '../../g_1867/step/buy_sell_par_shares'

module Engine
  module Game
    module G1864
      module Step
        class BuySellParShares < G1867::Step::BuySellParShares
          def ipo_type(entity)
            nikolaev = @game.corporation_by_id('N')
            if entity.type == :minor && entity.id != 'N' && !(nikolaev.ipoed || nikolaev.closed?)
              return 'Nikolaev must be the first corporation'
            end

            super
          end

          def can_buy?(entity, bundle)
            return super unless bundle&.corporation == @game.union_pacific
            return false if bundle.owner == @game.union_pacific && !@game.up_shares_purchasable_from_ipo?

            super
          end

          def can_sell?(entity, bundle)
            return false if bundle&.corporation == @game.union_pacific && !@game.up_operating?

            super
          end
        end
      end
    end
  end
end
