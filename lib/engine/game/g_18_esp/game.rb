# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'
require_relative '../cities_plus_towns_route_distance_str'
require_relative '../double_sided_tiles'

module Engine
  module Game
    module G18ESP
      class Game < Game::Base
        include_meta(G18ESP::Meta)
        include Entities
        include Map
        include CitiesPlusTownsRouteDistanceStr
        include DoubleSidedTiles

        attr_reader :can_build_mountain_pass, :special_merge_step, :can_buy_trains, :minors_stop_operating

        attr_accessor :player_debts, :double_headed_trains

        CURRENCY_FORMAT_STR = '₧%d'

        BANK_CASH = 99_999

        IMPASSABLE_HEX_COLORS = %i[gray red blue orange].freeze

        CERT_LIMIT = { 3 => 27, 4 => 20, 5 => 16, 6 => 13 }.freeze

        STARTING_CASH = { 3 => 860, 4 => 650, 5 => 520, 6 => 440 }.freeze

        NORTH_CORPS = %w[FdSB FdLR CFEA CFLG].freeze

        SPECIAL_MINORS = %w[].freeze

        TRACK_RESTRICTION = :permissive

        TILE_RESERVATION_BLOCKS_OTHERS = :single_slot_cities

        MOUNTAIN_PASS_TOKEN_HEXES = %w[L8 J10 H12 D12].freeze

        MOUNTAIN_PASS_TOKEN_COST = { 'L8' => 80, 'J10' => 80, 'H12' => 60, 'D12' => 100 }.freeze

        MOUNTAIN_PASS_TOKEN_BONUS = { 'L8' => 40, 'J10' => 40, 'H12' => 30, 'D12' => 50 }.freeze

        MINE_CLOSE_COST = 30

        MINOR_TAKEOVER_COST = 100

        SELL_AFTER = :operate

        SELL_BUY_ORDER = :sell_buy

        NORTH_SOUTH_DIVIDE = 13

        ARANJUEZ_HEX = 'F26'

        BASE_MINE_BONUS = { yellow: 30, green: 20, brown: 10, gray: 0 }.freeze

        # NEXT_SR_PLAYER_ORDER = :least_cash

        ALLOW_REMOVING_TOWNS = true

        DISCARDED_TRAIN_DISCOUNT = 50

        BANKRUPTCY_ALLOWED = false

        EBUY_PRES_SWAP = false

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false

        GAME_END_CHECK = { final_phase: :one_more_full_or_set }.freeze

        MINOR_TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }].freeze
        MAJOR_TILE_LAYS = [
          { lay: true, upgrade: true, cost: 0 },
          { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        MARKET = [
          %w[50 55 60 65 70p 75p 80p 85p 90p 95p 100p 105 110 115 120
             126 132 138 144 151 158 165 172 180 188 196 204 213 222 231 240 250 260
             270 280 295 310 325 340 360 380 400],
        ].freeze

        PHASES = [{
          name: '2',
          train_limit: { minor: 2, major: 4 },
          tiles: %i[yellow],
          operating_rounds: 1,
          status: %w[can_buy_companies],
        },
                  {
                    name: '3',
                    on: '3',
                    train_limit: { minor: 2, major: 4 },
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: %w[can_buy_companies],
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: { minor: 1, major: 3 },
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: %w[can_buy_companies],
                  },
                  {
                    name: '5',
                    on: '5',
                    train_limit: { minor: 1, major: 3 },
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                    status: %w[],
                  },
                  {
                    name: '6',
                    on: '6',
                    train_limit: { minor: 1, major: 2 },
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                    status: %w[],
                  },
                  {
                    name: '8',
                    on: '8',
                    train_limit: { minor: 1, major: 2 },
                    tiles: %i[yellow green brown gray],
                    operating_rounds: 3,
                    status: %w[],
                  }].freeze

        TRAINS = [

          {
            name: '2P',
            distance: 2,
            price: 0,
            num: 1,
          },

          {
            name: '2',
            distance: 2,
            price: 100,
            num: 12,
            rusts_on: '4',
            variants: [
              {
                name: '1+2',
                distance: [{ 'nodes' => %w[town halt], 'pay' => 2, 'visit' => 2 },
                           { 'nodes' => %w[city offboard town halt], 'pay' => 1, 'visit' => 1 }],
                track_type: :narrow,
                no_local: true,
                price: 100,
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            num: 9,
            rusts_on: '6',
            variants: [
              {
                name: '2+3',
                distance: [{ 'nodes' => %w[town halt], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => %w[city offboard town halt], 'pay' => 2, 'visit' => 2 }],
                track_type: :narrow,
                price: 200,
              },
            ],
            events: [{ 'type' => 'south_majors_available' },
                     { 'type' => 'companies_bought_150' },
                     { 'type' => 'mountain_pass' },
                     { 'type' => 'can_buy_trains' }],
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            num: 7,
            rusts_on: '8',
            variants: [
              {
                name: '3+4',
                distance: [{ 'nodes' => %w[town halt], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => %w[city offboard town halt], 'pay' => 3, 'visit' => 3 }],
                track_type: :narrow,
                price: 300,
              },
            ],
            events: [
              { 'type' => 'companies_bought_200' },
            ],
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 5,
            variants: [
              {
                name: '4+5',
                distance: [{ 'nodes' => %w[town halt], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => %w[city offboard town halt], 'pay' => 4, 'visit' => 4 }],
                track_type: :narrow,
                price: 500,
              },
            ],
            events: [{ 'type' => 'close_companies' },
                     { 'type' => 'minors_stop_operating' }],
          },
          {
            name: '6',
            distance: 6,
            price: 600,
            num: 3,
            variants: [
              {
                name: '5+6',
                distance: [{ 'nodes' => %w[town halt], 'pay' => 6, 'visit' => 6 },
                           { 'nodes' => %w[city offboard town halt], 'pay' => 5, 'visit' => 5 }],
                track_type: :narrow,
                price: 600,
              },
            ],
            events: [{ 'type' => 'float_60' }],
          },

          {
            name: '8',
            distance: 8,
            price: 800,
            num: 30,
            variants: [
                      {
                        name: '6+8',
                        distance: [{ 'nodes' => %w[town halt], 'pay' => 8, 'visit' => 8 },
                                   { 'nodes' => %w[city offboard town halt], 'pay' => 6, 'visit' => 6 }],
                        track_type: :narrow,
                        price: 800,
                      },
                    ],

          },
          ].freeze

        # These trains don't count against train limit, they also don't count as a train
        # against the mandatory train ownership. They cant the bought by another corporation.
        EXTRA_TRAINS = %w[2P].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
                'south_majors_available' => ['South Majors Available',
                                             'Major Corporations in the south map can open'],
                'companies_bought_150' => ['Companies 150%', 'Companies can be bought in for maximum 150% of value'],
                'companies_bought_200' => ['Companies 200%', 'Companies can be bought in for maximum 200% of value'],
                'minors_stop_operating' => ['Minors stop operating'],
                'float_60' => ['60% to Float', 'Corporations must have 60% of their shares sold to float'],
                'mountain_pass' => ['Can build mountain passes'],
                'can_buy_trains' => ['Corporations can buy trains from other corporations']
              ).freeze

        def init_tile_groups
          self.class::TILE_GROUPS
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            Engine::Step::SelectionAuction,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::Acquire,
            Engine::Step::DiscardTrain,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Assign,
            Engine::Step::Exchange,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialChoose,
            Engine::Step::Track,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def setup
          @corporations, @future_corporations = @corporations.partition do |corporation|
            corporation.type == :minor || north_corp?(corporation)
          end
          @corporations.each { |c| c.shares.first.double_cert = true if c.type == :minor }
          @future_corporations.each { |c| c.shares.last.buyable = false }
          @minors_stop_operating = false

          @company_trains = {}
          @company_trains['P2'] = find_and_remove_train_for_minor('2-0')
          @company_trains['P3'] = find_and_remove_train_for_minor('2P-0', buyable: false)
          @perm2_ran_aranjuez = false

          setup_company_price(1)

          # Initialize the player depts, if player have to take an emergency loan
          init_player_debts

          @tile_groups = init_tile_groups
          initialize_tile_opposites!
          @unused_tiles = []
          @double_headed_trains = []

          # place tokens on mountain passes

          MOUNTAIN_PASS_TOKEN_HEXES.each do |hex|
            block_token = Token.new(nil, price: 0, logo: '/logos/18_esp/block.svg')
            hex_by_id(hex).tile.cities.first.exchange_token(block_token)
            hex_by_id(hex).tile.cities.first.exchange_token(block_token)
          end
        end

        def setup_company_price(mulitplier)
          @companies.each { |company| company.max_price = company.value * mulitplier }
        end

        def init_stock_market
          Engine::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                  multiple_buy_types: self.class::MULTIPLE_BUY_TYPES,
                                  zigzag: :flip)
        end

        def operating_order
          @corporations.select(&:floated?).sort
        end

        def find_and_remove_train_for_minor(train_id, buyable = true)
          train = train_by_id(train_id)
          @depot.remove_train(train)
          train.buyable = buyable
          train.reserved = true
          train
        end

        def init_company_abilities
          northern_corps = @corporations.select { |c| north_corp?(c) }
          random_corporation = northern_corps[rand % northern_corps.size]
          @companies.each do |company|
            next unless (ability = abilities(company, :shares))

            real_shares = []
            ability.shares.each do |share|
              case share
              when 'random_president'
                share = random_corporation.shares[0]
                real_shares << share
                company.desc = "Purchasing player takes a president's share (20%) of #{random_corporation.name} \
                (The president's share is randomized) and immediately sets its par value. \
                It closes when #{random_corporation.name} buys its first train."
                @log << "#{company.name} comes with the president's share of #{random_corporation.name}"
                company.add_ability(Ability::Close.new(
                type: :close,
                when: 'bought_train',
                corporation: random_corporation.name,
              ))
              else
                real_shares << share_by_id(share)
              end
            end

            ability.shares = real_shares
          end
        end

        def tile_lays(entity)
          return MINOR_TILE_LAYS if entity.type == :minor

          MAJOR_TILE_LAYS
        end

        def north_corp?(entity)
          return false unless entity&.corporation?

          NORTH_CORPS.include? entity.name
        end

        def init_player_debts
          @player_debts = @players.to_h { |player| [player.id, { debt: 0, interest: 0 }] }
        end

        def player_debt(player)
          @player_debts[player.id][:debt]
        end

        def player_interest(player)
          @player_debts[player.id][:interest]
        end

        def player_value(player)
          player.value - player_debt(player) - player_interest(player)
        end

        def event_south_majors_available!
          @corporations.concat(@future_corporations)
          @log << '-- Major corporations in the south now available --'
        end

        def event_companies_bought_150!
          setup_company_price(1.5)
        end

        def event_mountain_pass!
          @can_build_mountain_pass = true
        end

        def event_companies_bought_200!
          setup_company_price(2)
        end

        def event_can_buy_trains!
          @log << 'Corporations can buy trains from other corporations'
          @can_buy_trains = true
        end

        def event_minors_stop_operating!
          @log << 'Minors stop operating'
          @minors_stop_operating = true

          @corporations.each { |c| c.shares.last.buyable = true if !c.ipoed && c.type != :minor }
        end

        def event_float_60!
          @corporations.each do |c|
            next if c.type == :minor || c.floated?

            c.shares.last&.buyable = true
            c.float_percent = 60
          end

          @full_cap = true
        end

        def home_token_can_be_cheater
          true
        end

        def north_hex?(hex)
          hex.y < NORTH_SOUTH_DIVIDE
        end

        def mine_hexes
          @mine_hexes ||= Map::MINE_HEXES
        end

        def mine_hex?(hex)
          mine_hexes.any?(hex.name)
        end

        def opened_mountain_passes
          @opened_mountain_passes ||= {}
        end
      end
    end
  end
end
