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

        # General Constants
        BANK_CASH = 12_000
        CERT_LIMIT = { 3 => 20, 4 => 15, 5 => 12, 6 => 11 }.freeze
        CURRENCY_FORMAT_STR = '$%d'
        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :full_or }.freeze
        SELL_BUY_ORDER = :sell_buy_sell
        STARTING_CASH = { 3 => 700, 4 => 525, 5 => 425, 6 => 375 }.freeze
        TILE_RESERVATION_BLOCKS_OTHERS = true
        TRACK_RESTRICTION = :permissive

        # OR Constants
        FIRST_TURN_EXTRA_TILE_LAYS = [{ lay: true, upgrade: false }].freeze
        MAJOR_TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze
        MINOR_TILE_LAYS = [{ lay: true, upgrade: true }].freeze

        def setup
          @recently_floated = []
          @minors.each do |minor|
            train = @depot.upcoming[0]
            train.buyable = false
            buy_train(minor, train, :free)
            Array(minor.coordinates).each { |coordinates| hex_by_id(coordinates).tile.cities[0].add_reservation!(minor) }
          end
        end

        # OR Stuff
        def or_round_finished
          @recently_floated = []
        end

        def tile_lays(entity)
          operator = entity.company? ? entity.owner : entity
          extra_tile_lays = @recently_floated&.include?(operator) ? FIRST_TURN_EXTRA_TILE_LAYS : []
          if operator.corporation?
            extra_tile_lays + MAJOR_TILE_LAYS
          elsif operator.minor?
            extra_tile_lays + MINOR_TILE_LAYS
          else
            super
          end
        end

        # SR stuff

        def float_corporation(corporation)
          @recently_floated << corporation

          super
        end
      end
    end
  end
end
