# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18PA
      class Game < Game::Base
        include_meta(G18PA::Meta)
        include Entities
        include Map

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :semi_restrictive
        SELL_BUY_ORDER = :sell_buy
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        CURRENCY_FORMAT_STR = '$%s'

        MUST_BUY_TRAIN = :always
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        SELL_AFTER = :operate
        SOLD_SHARES_DESTINATION = :corporation
        MARKET_SHARE_LIMIT = 80 # percent
        EBUY_FROM_OTHERS = :never

        BANK_CASH = 8_000

        CERT_LIMIT = {
          3 => { 7 => 17, 6 => 16, 5 => 15, 4 => 14, 3 => 13, 2 => 12, 1 => 11, 0 => 11 },
          4 => { 7 => 14, 6 => 13, 5 => 12, 4 => 11, 3 => 10, 2 => 9, 1 => 8, 0 => 8 },
          5 => { 7 => 12, 6 => 11, 5 => 10, 4 => 9, 3 => 8, 2 => 7, 1 => 6, 0 => 6 },
        }.freeze

        STARTING_CASH = { 3 => 500, 4 => 400, 5 => 350 }.freeze

        MARKET = [
          %w[90 100 110 125 140 160 180 200 225 250 275 300],
          %w[80 90 100 110p 125 140 160 180 200 225 250 275],
          %w[70 80 90p 100p 110 125 140 160 180 200],
          %w[60 70p 80p 90 100 110 125],
          %w[50 60 70 80 90],
        ].freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 2 },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                  },
                  {
                    name: '5',
                    on: '5',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                    operating_rounds: 2,
                  },
                  {
                    name: '3D',
                    on: '3D',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                    operating_rounds: 2,
                  }].freeze

        TRAINS = [
                  {
                    name: '2',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    price: 100,
                    rusts_on: '4',
                    num: 9,
                  },
                  {
                    name: '3',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    price: 200,
                    rusts_on: '3D',
                    num: 4,
                  },
                  # this train is reserved for the NYC
                  {
                    name: '3(NYC)',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    price: 0,
                    rusts_on: '3D',
                    num: 1,
                    reserved: true,
                  },
                  {
                    name: '4',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    price: 400,
                    num: 3,
                    events: [{ 'type' => 'nyc_forms' }, { 'type' => 'may_convert_acquire' }],
                  },
                  {
                    name: '5',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    price: 500,
                    num: 99,
                    # events: [{ 'type' => 'convert_2r_trains' }],
                  },
                  # The 2R trains are reserved for corps which buy in Minors 4-9
                  {
                    name: '2R',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                               { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
                    price: 0,
                    num: 6,
                    reserved: true,
                  },
                  {
                    name: '3D',
                    distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3, 'multiplier' => 2 },
                               { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                    price: 600,
                    num: 99,
                    available_on: '5',
                  },
        ].freeze

        SCRANTON_HEX = 'G12'
        SCRANTON_MARKER_ICON = 'mine'
        SCRANTON_MARKER_COST = 40
        DOUBLING_TOKEN_CORPS = %w[B&A ERIE PRR].freeze
        MINOR_UPGRADES = %w[yellow green].freeze

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::SelectionAuction,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::SpecialToken,
            G18PA::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18PA::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
          ], round_num: round_num)
        end

        def setup
          @scranton_marker_ability = Engine::Ability::Description.new(type: 'description', description: 'Scranton Token')

          # place the home station for all corporations and minors except NYC.
          @corporations.each do |corporation|
            next if corporation.id == 'NYC'

            tile = hex_by_id(corporation.coordinates).tile
            tile.cities[corporation.city || 0].place_token(corporation, corporation.tokens.first, free: true)
          end
        end

        def scranton_marker_available?
          hex_by_id(SCRANTON_HEX).tile.icons.any? { |icon| icon.name == SCRANTON_MARKER_ICON }
        end

        def scranton_marker?(entity)
          return false if !entity.corporation? || entity.type == :minor

          !scranton_markers(entity).empty?
        end

        def scranton_markers(entity)
          entity.all_abilities.select { |ability| ability.description == @scranton_marker_ability.description }
        end

        def connected_to_scranton?(entity)
          graph.reachable_hexes(entity).include?(hex_by_id(SCRANTON_HEX))
        end

        def can_buy_scranton_marker?(entity)
          return false if !entity.corporation? || entity.type == :minor

          scranton_marker_available? &&
            !scranton_marker?(entity) &&
            buying_power(entity) >= SCRANTON_MARKER_COST &&
            connected_to_scranton?(entity)
        end

        def buy_scranton_marker(entity)
          return unless can_buy_scranton_marker?(entity)

          entity.spend(SCRANTON_MARKER_COST, @bank)
          entity.add_ability(@scranton_marker_ability.dup)
          @log << "#{entity.name} buys a Scranton bonus token for $#{SCRANTON_MARKER_COST}."

          tile_icons = hex_by_id(SCRANTON_HEX).tile.icons
          tile_icons.delete_at(tile_icons.index { |icon| icon.name == SCRANTON_MARKER_ICON })
        end
      end
    end
  end
end
