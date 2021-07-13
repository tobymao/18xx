# frozen_string_literal: true

require_relative '../../g_1867/step/buy_sell_par_shares'

module Engine
  module Game
    module G1861
      module Step
        class BuySellParShares < G1867::Step::BuySellParShares
          def ipo_type(entity)
            if entity.type == :minor && entity.id != 'N' && !@game.corporation_by_id('N').ipoed
              return 'Nikolaev must be the first corporation'
            end

            return 'No home token locations are available' if entity.type == :major && @game.home_token_locations(entity).empty?

            super
          end
        end
      end
    end
  end
end
