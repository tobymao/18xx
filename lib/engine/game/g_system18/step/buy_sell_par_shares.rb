# frozen_string_literal: true

require_relative '../../../step/buy_sell_par_shares'

module Engine
  module Game
    module GSystem18
      module Step
        class BuySellParShares < Engine::Step::BuySellParShares
          def can_dump?(entity, bundle)
            if @game.respond_to?("map_#{@game.cmap_name}_can_dump?")
              return @game.send("map_#{@game.cmap_name}_can_dump?", entity, bundle)
            end

            super
          end
        end
      end
    end
  end
end
