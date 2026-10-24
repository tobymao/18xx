# frozen_string_literal: true

require_relative '../../g_1867/step/buy_sell_par_shares'

module Engine
  module Game
    module G1861
      module Step
        class BuySellParShares < G1867::Step::BuySellParShares
          def ipo_type(entity)
            return 'No home token locations are available' if entity.type == :major && @game.home_token_locations(entity).empty?

            first_minor = @game.first_minor
            if entity.type == :minor && entity != first_minor && !(first_minor.ipoed || first_minor.closed?)
              return "#{first_minor.full_name} must be the first corporation"
            end

            super
          end
        end
      end
    end
  end
end
