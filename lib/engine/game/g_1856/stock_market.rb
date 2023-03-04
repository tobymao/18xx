# frozen_string_literal: true

module Engine
  module Game
    module G1856
      class StockMarket < Engine::StockMarket
        attr_writer :game

        def move(corporation, coordinates, force: false)
          return super if corporation != @game.national
          # National may not move unless it's owned a permanent train
          return unless @game.national_ever_owned_permanent

          share_price = share_price(coordinates)
          # National may never close.
          return super unless share_price.types.include?(:close)

          @game.log << "#{@game.national.name} may not close"
        end
      end
    end
  end
end
