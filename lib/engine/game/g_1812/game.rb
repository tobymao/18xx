# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'
require_relative '../company_price_up_to_face'

module Engine
  module Game
    module G1812
      class Game < Game::Base
        include_meta(G1812::Meta)
        include Entities
        include Map
        include CompanyPriceUpToFace

        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :semi_restrictive
        CURRENCY_FORMAT_STR = '£%s'

        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :left_block_pres

        BANK_CASH = { 2 => 4000, 3 => 6000, 4 => 8000 }.freeze

        CERT_LIMIT = { 2 => 15, 3 => 10, 4 => 10 }.freeze

        STARTING_CASH = 195

        MARKET = [
          %w[
            40
            45
            50p
            55p
            60p
            65p
            70p
            80p
            90p
            100p
            110p
            120p
            135p
            150
            165
            180
            200
            220
            245
            270
            300
            330
            360
            400
          ],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies minors_can_merge],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            status: %w[can_buy_companies minors_can_merge cannot_open_minors],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: %w[can_par minors_can_merge cannot_open_minors tradeins_allowed],
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            variants: [
              {
                name: '1G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 90,
              },
            ],
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 200,
            rusts_on: '5',
            variants: [
              {
                name: '2G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 180,
              },
            ],
          },
          {
            name: '3+1',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 1, 'visit' => 99 }],
            price: 220,
            rusts_on: '3D',
            variants: [
              {
                name: '2+1G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 200,
              },
            ],
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 400,
            variants: [
              {
                name: '3+2G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 5, 'visit' => 5 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 360,
              },
            ],
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 1, 'visit' => 99 }],
            price: 500,
            variants: [
              {
                name: '4+2G',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 6 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 460,
              },
            ],
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '3D',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3, 'multiplier' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 750,
            variants: [
              {
                name: '2+2GD',
                distance: [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 6, 'multiplier' => 2 },
                           { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
                price: 460,
              },
            ],
          },
        ].freeze

        def new_auction_round
          Engine::Round::Auction.new(self, [
            Engine::Step::SelectionAuction,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def setup_preround
          # randomize the private companies, choose an amount equal to double the player count, sort numerically
          @companies = @companies.sort_by { rand }.take(@players.size * 2).sort_by(&:sym)
          @minors = @minors.sort_by { rand }.take((@players.size * 2) + 2) if @optional_rules&.include?(:remove_some_minors)
        end

        def bank_sort(entities)
          minors, corps = entities.partition(&:minor?)
          minors.sort_by { |m| m.name.to_i } + super(corps)
        end

        def setup
          setup_company_price_up_to_face
          @log << "Minors in the game: #{@minors.map(&:name).sort.join(', ')}" if @optional_rules&.include?(:remove_some_minors)
        end

        def num_trains(train)
          num_players = @players.size

          case train[:name]
          when '3'
            num_players == 2 ? 3 : num_players + 2
          when '4'
            num_players
          else
            99
          end
        end

        def train_limit(entity)
          return super unless entity.minor?

          case @phase.name
          when '2' || '3'
            2
          when '4'
            1
          when '5'
            0
          end
        end

        def can_par?(corporation, parrer)
          @phase.status.include?('can_par')

          super
        end

        NORTH_HEXES = %w[A4 A8 F1].freeze
        SOUTH_HEXES = %w[C20 E20 F19].freeze
        PORT_HEXES = %w[F3 G4 G6 G8 H9 H17 H19].freeze
        MINE_HEXES = %w[B15 D7 D17 E2 E6].freeze
        GTRAINS = %w[1G 2G 2+1G 3+2G 4+2G 2+2GD].freeze
        F3_PORT = ['F3'].freeze
        G6_PORT = ['G6'].freeze
        H9_PORT = ['H9'].freeze

        def mine_port_bonus
          @hexes.find { |hex| hex.coordinates == 'I3' }.tile.offboards.first
        end

        def ns_bonus
          @hexes.find { |hex| hex.coordinates == 'I1' }.tile.offboards.first
        end

        def revenue_for(route, stops)
          revenue = super
          hex = route.hexes
          gtrain = route.train.variant.name?(GTRAINS)

          revenue += mine_port_bonus if gtrain && hex.id.include?(MINE_HEXES) && hex.id.include?(PORT_HEXES)
          revenue += ns_bonus if (hex.first.id(NORTH_HEXES) && hex.last.id(SOUTH_HEXES)) ||
                                 (hex.first.id(SOUTH_HEXES) && hex.last.id(NORTH_HEXES))
          revenue += 10 if gtrain && hex.id == F3_PORT && route.corporation.assigned?(p3_company)
          revenue += 10 if gtrain && hex.id == F3_PORT && route.corporation.assigned?(p8_company)
          revenue += 10 if gtrain && hex.id == H9_PORT && route.corporation.assigned?(p9_company)
          revenue += 20 if gtrain && hex.id == G6_PORT && route.corporation.assigned?(p12_company)

          revenue
        end

        def p3_company
          @p3 ||= @company.by_id('P3')
        end

        def p8_company
          @p8 ||= @company.by_id('P8')
        end

        def p9_company
          @p9 ||= @company.by_id('P9')
        end

        def p12_company
          @p12 ||= @company.by_id('P12')
        end
      end
    end
  end
end
