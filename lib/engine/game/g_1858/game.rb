# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative 'market'
require_relative 'trains'
require_relative '../base'

module Engine
  module Game
    module G1858
      class Game < Game::Base
        include_meta(G1858::Meta)
        include G1858::Map
        include G1858::Entities
        include G1858::Market
        include G1858::Trains
        include CitiesPlusTownsRouteDistanceStr

        HOME_TOKEN_TIMING = :float

        # FIXME: second tile lay only costs 10 if either first or second lay
        # only adds metre gauge track.
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: true, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        def setup
          super
        end

        def init_round
          # FIXME: the initial stock round isn't *quite* a normal stock round,
          # you cannot start public companies in the first stock round.
          stock_round
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round
          super
        end

        def home_token_locations(_corporation)
          # FIXME/TODO: when starting a public company after the start of phase 5
          # it can choose any unoccupied city space for its first token.
          open_locations = hexes.select do |hex|
            hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) && city.tokens.none? }
          end
          return open_locations
        end
      end
    end
  end
end
