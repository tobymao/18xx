# frozen_string_literal: true

require_relative '../base'
require_relative 'entities'
require_relative 'map'
require_relative 'market'
require_relative 'meta'
require_relative 'tiles'
require_relative 'trains'

module Engine
  module Game
    module G18Ardennes
      class Game < Game::Base
        include_meta(G18Ardennes::Meta)
        include Entities
        include Map
        include Market
        include Tiles
        include Trains

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :par

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G18Ardennes::Step::HomeHexTile,
            G18Ardennes::Step::MinorAuction,
          ])
        end
      end
    end
  end
end
