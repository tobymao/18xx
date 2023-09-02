# frozen_string_literal: true

require_relative '../base'
require_relative '../stubs_are_restricted'
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
        include StubsAreRestricted
        include Entities
        include Map
        include Market
        include Tiles
        include Trains

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :par

        def setup
          super

          setup_tokens
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G18Ardennes::Step::HomeHexTile,
            G18Ardennes::Step::MinorAuction,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18Ardennes::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
          ], round_num: round_num)
        end

        def route_distance_str(route)
          towns = route.visited_stops.count(&:town?)
          cities = route_distance(route) - towns
          if towns.positive? && route.train.name != '5D'
            "#{cities}+#{towns}"
          else
            cities.to_s
          end
        end
      end
    end
  end
end
