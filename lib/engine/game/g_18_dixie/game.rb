# frozen_string_literal: true

require_relative 'meta'
require_relative 'corporations'
require_relative 'tiles'
require_relative 'map'
require_relative 'market'
require_relative 'phases'
require_relative 'trains'
require_relative 'minors'
require_relative 'companies'
require_relative '../base'
require_relative '../cities_plus_towns_route_distance_str'

module Engine
  module Game
    module G18Dixie
      class Game < Game::Base
        include_meta(G18Dixie::Meta)
        include G18Dixie::Tiles
        include G18Dixie::Map
        include G18Dixie::Market
        include G18Dixie::Phases
        include G18Dixie::Trains
        include G18Dixie::Companies
        include G18Dixie::Minors
        include G18Dixie::Corporations

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')

        include CitiesPlusTownsRouteDistanceStr

        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy_sell
        TILE_RESERVATION_BLOCKS_OTHERS = true
        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 12_000

        def setup
          @minors.each do |minor|
            train = @depot.upcoming[0]
            train.buyable = false
            buy_train(minor, train, :free)
            Array(minor.coordinates).each { |coordinates| hex_by_id(coordinates).tile.cities[0].add_reservation!(minor) }
          end
        end

        CERT_LIMIT = { 3 => 20, 4 => 15, 5 => 12, 6 => 11 }.freeze

        STARTING_CASH = { 3 => 700, 4 => 525, 5 => 425, 6 => 375 }.freeze
        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :full_or }.freeze
      end
    end
  end
end
