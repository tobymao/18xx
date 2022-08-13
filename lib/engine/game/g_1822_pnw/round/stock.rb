# frozen_string_literal: true

require_relative '../../g_1822/round/stock'

module Engine
  module Game
    module G1822PNW
      module Round
        class Stock < Engine::Game::G1822::Round::Stock
          def float_minor(bid)
            minor = @game.find_corporation(bid.company)
            return super unless @game.regional_railway?(minor)

            buy_company(bid)
            bid.company.value = 200

            minor.reservation_color = :white
            minor.owner = bid.entity
            minor_city = @game.hex_by_id(minor.coordinates).tile.cities.find { |c| c.reserved_by?(minor) }
            minor_city.place_token(minor, minor.tokens.first, free: true, check_tokenable: false)
            minor.share_price = @game.stock_market.par_prices.find { |pp| pp.price == 100 }
            @log << "#{minor.id} places a token on #{minor_city.hex.name} (#{minor_city.hex.location_name})"
          end
        end
      end
    end
  end
end
