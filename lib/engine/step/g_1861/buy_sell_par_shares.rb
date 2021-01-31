# frozen_string_literal: true

require_relative '../g_1867/buy_sell_par_shares'

module Engine
  module Step
    module G1861
      class BuySellParShares < G1867::BuySellParShares
        def ipo_type(entity)
          if entity.type == :minor && entity.id != 'N' && !@game.corporation_by_id('N').ipoed
            return 'Nikolaev must be the first corporation'
          end

          if entity.type == :major && @game.home_token_locations(entity).empty?
            return 'No home token locations are available'
          end

          super
        end
      end
    end
  end
end
