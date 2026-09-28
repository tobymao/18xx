# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'

module Engine
  module Game
    module G18Africa
      # Data skeleton: map, entities, market, trains and phases. Rounds use the engine defaults;
      # the hidden certificate deck, the economy, concessions and the other rules follow in later PRs.
      class Game < Game::Base
        include_meta(G18Africa::Meta)
        include Entities
        include Map

        CURRENCY_FORMAT_STR = '£%s'
        BANK_CASH = 14_000
        BANKRUPTCY_ALLOWED = false

        STARTING_CASH = { 2 => 782, 3 => 694, 4 => 606, 5 => 518 }.freeze

        # Certificate limit by number of remaining companies: none, one or two+ closed [2.4]
        CERT_LIMIT = {
          2 => { 7 => 28, 6 => 23, 5 => 19 },
          3 => { 9 => 24, 8 => 21, 7 => 18 },
          4 => { 9 => 18, 8 => 16, 7 => 14 },
          5 => { 9 => 15, 8 => 13, 7 => 11 },
        }.freeze

        # Number of companies chosen at random for the game [1.3]
        CORPORATIONS_IN_GAME = { 2 => 7, 3 => 9, 4 => 9, 5 => 9 }.freeze

        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :float
        MUST_BUY_TRAIN = :never
        # New track must be reachable, upgrades must use new track or change a City/Town [3.2]
        TRACK_RESTRICTION = :semi_restrictive

        # Nothing done in the Stock Round affects the Market Value [7]
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :none
        POOL_SHARE_DROP = :none
        SOLD_OUT_INCREASE = false
        MUST_SELL_IN_BLOCKS = false
        MARKET_SHARE_LIMIT = 100

        GAME_END_CHECK = { bank: :current_or, stock_market: :current_or }.freeze

        # Up to four yellow tiles or a single upgrade [3.2]
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: :not_if_upgraded, upgrade: false },
          { lay: :not_if_upgraded, upgrade: false },
          { lay: :not_if_upgraded, upgrade: false },
        ].freeze

        MARKET = [
          %w[0c 5 10 22 34 45 56 58 61p 64p 67p 71p 76p 82p 90p 100p 112 126 142 160 180 205 230 255
             280 300 320 340 360 380 400e 420e 440e 460e],
        ].freeze

        # All tiles are available from the start and the train limit is always 2 [7].
        # After the last 4E is bought every train type becomes available [3.6.1].
        PHASES = [
          { name: '2', train_limit: 2, tiles: %i[yellow green brown gray], operating_rounds: 2 },
          { name: '3', on: '3', train_limit: 2, tiles: %i[yellow green brown gray], operating_rounds: 2 },
          { name: '4E', on: '4E', train_limit: 2, tiles: %i[yellow green brown gray], operating_rounds: 2 },
          { name: 'All', train_limit: 2, tiles: %i[yellow green brown gray], operating_rounds: 2 },
        ].freeze

        # Towns never count against the distance; only Cities do [3.4.1].
        # 'E' trains visit any number of Cities and count the best four stops [3.4.3].
        TRAINS = [
          {
            name: '2',
            salvage: 180,
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 180,
            num: 6,
          },
          {
            name: '3',
            salvage: 180,
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 300,
            num: 4,
          },
          {
            name: '4E',
            salvage: 300,
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 99 }],
            requires_token: false,
            price: 450,
            num: 3,
            events: [{ 'type' => 'all_trains_available', 'when' => 3 }],
          },
          {
            name: '3+3',
            salvage: 500,
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            multiplier: 2,
            price: 700,
            num: 3,
            available_on: 'All',
          },
          {
            name: '3+3T',
            salvage: 650,
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            multiplier: 2,
            price: 850,
            num: 3,
            available_on: 'All',
          },
          {
            name: '4+4+4E',
            salvage: 750,
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 99 }],
            requires_token: false,
            multiplier: 3,
            price: 1000,
            num: 3,
            available_on: 'All',
          },
          {
            name: '4+4+4T',
            salvage: 850,
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            multiplier: 3,
            price: 1200,
            num: 3,
            available_on: 'All',
          },
        ].freeze

        def event_all_trains_available!
          @log << '-- The last 4E has been bought: all trains are now available --'
          @phase.next!
          @depot.depot_trains(clear: true)
        end

        def num_trains(train)
          # With two players, remove one '2' and one '3' train [1.2]
          return train[:num] - 1 if @players.size == 2 && %w[2 3].include?(train[:name])

          super
        end

        def setup_preround
          remove_unused_corporations!
        end

        def setup
          remove_home_reservations(@removals)
          mark_commodities
        end

        def remove_unused_corporations!
          keep = CORPORATIONS_IN_GAME[@players.size]
          removed = @corporations.sort_by { rand }.drop(keep)
          removed.each do |corporation|
            @corporations.delete(corporation)
            corporation.close!
            @removals << corporation
          end
          @log << "Companies removed from the game: #{removed.map(&:name).sort.join(', ')}"
        end

        # Starting spaces of removed Companies are not reserved [3.3.1]
        def remove_home_reservations(corporations)
          corporations.each do |corporation|
            hex_by_id(corporation.coordinates).tile.cities.each do |city|
              city.reservations.delete(corporation)
            end
          end
        end

        # Commodity locations get a diamond, destination ports a plaque with the bonus and the resource
        # (like 18India); both are sticky and stay when tiles are laid [3.4.5]
        def mark_commodities
          CONCESSIONS.each do |id, data|
            add_sticky_icon(data[:commodity], id.downcase)
            data[:ports].each { |port| add_sticky_icon(port, "#{id.downcase}-#{data[:bonus]}") }
          end
        end

        def add_sticky_icon(hex_id, image)
          hex_by_id(hex_id).tile.icons << Part::Icon.new("18_africa/#{image}", nil, true, nil, true, large: true)
        end

        # Commodity diamonds and port plaques are drawn without the round background of large icons,
        # so they cannot be mistaken for tokens
        def decorate_marker(icon)
          return unless CONCESSIONS.key?(icon.name.split('-').first.upcase)

          { shape: :none }
        end

        # Variable Cities are marked hide: their "?+X" label replaces the printed revenue [3.4.4]
        def hide_city_revenue?
          true
        end

        # Round definitions use engine defaults only; the custom steps follow in later PRs
        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
          ], round_num: round_num)
        end
      end
    end
  end
end
