# frozen_string_literal: true

# add rules: 1/2 tile lays, half/full pay,
# sell/buy certs from bank, no sales until complete OR

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18Texas
      class Game < Game::Base
        include_meta(G18Texas::Meta)

        CURRENCY_FORMAT_STR = '$%d'
        BANK_CASH = 8_000
        CERT_LIMIT = { 2 => 21, 3 => 15, 4 => 12, 5 => 10 }.freeze
        STARTING_CASH = { 2 => 670, 3 => 500, 4 => 430, 5 => 400 }.freeze
        CAPITALIZATION = :incremental
        HOME_TOKEN_TIMING = :float
        TRACK_RESTRICTION = :semi_restrictive
        LAYOUT = :pointy
        AXES = { x: :number, y: :letter }.freeze
        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate
        TREASURY_SHARE_LIMIT = 50

        TOKEN_FEE = {
          'T&P' => 120,
          'SP' => 120,
          'MP' => 100,
          'MKT' => 80,
          'SSW' => 80,
          'SAA' => 80,
        }.freeze

        # rubocop:disable Layout/LineLength
        TILES = {
          '5' => 4,
          '6' => 4,
          '7' => 5,
          '8' => 18,
          '9' => 18,
          '57' => 4,
          '202' => 3,
          '14' => 3,
          '15' => 4,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 1,
          '21' => 1,
          '22' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '30' => 1,
          '31' => 1,
          '619' => 3,
          '624' => 1,
          '625' => 1,
          '626' => 1,
          '39' => 1,
          '40' => 1,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 2,
          '46' => 2,
          '47' => 1,
          '70' => 1,
          '216' => 3,
          '611' => 5,
          '627' => 1,
          '628' => 1,
          '629' => 1,
          '511' =>
          {
            'count' => 4,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;label=Y;path=a:0,b:_0;path=a:2,b:_0;path=a:4,b:_0',
          },
          '512' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;label=Y;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
          },
        }.freeze
        # rubocop:enable Layout/LineLength

        MARKET = [
          %w[82 90 100 110 122 135 150 165 180 200 220 245 270 300 330 360 400],
          %w[82 90 100 110 122 135 150 165 180 200 220 245 270],
          %w[70 75 82 90 100p 110 122 135 150 165 180],
          %w[65 70 75 82p 90p 100 110 122],
          %w[60 65 70p 75p 82 90],
          %w[50 60 65 70 75],
          %w[40 50 60 65],
        ].freeze

        PHASES = [
        {
          name: '2',
          train_limit: 4,
          tiles: [:yellow],
          operating_rounds: 1,
        },
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
          operating_rounds: 3,
        },
        {
          name: '6',
          on: '6',
          train_limit: 2,
          tiles: %i[yellow green brown],
          operating_rounds: 3,
        },
        {
          name: '8',
          on: '8',
          train_limit: 2,
          tiles: %i[yellow green brown gray],
          operating_rounds: 3,
        },
      ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 5,
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            rusts_on: '6',
            num: 4,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '8',
            num: 3,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 2,
            events: [{ 'type' => 'close_companies' }],
          },
          { name: '6', distance: 6, price: 600, num: 2 },
          { name: '8', distance: 8, price: 800, num: 4 },
        ].freeze

        COMPANIES = [
          {
            name: 'A',
            value: 50,
            revenue: 10,
            desc: 'No special ability',
            sym: 'A',
          },
          {
            name: 'B',
            value: 80,
            revenue: 15,
            desc: 'No special ability',
            sym: 'B',
          },          {
            name: 'C',
            value: 200,
            revenue: 5,
            desc: 'The purchaser of this private company receives the president\'s certificate of '\
                  'the T&P Railroad and must immediately set its par value. The T&P automatically '\
                  'floats once this private company is purchased and is an exception to the normal '\
                  'rule.',
            abilities: [{ type: 'shares', shares: 'T&P_0' }],
            sym: 'C',
          },          {
            name: 'D',
            value: 210,
            revenue: 20,
            desc: 'The purchaser of this private company receives a share of '\
                  'the T&P Railroad.',
            abilities: [{ type: 'shares', shares: 'T&P_1' }],
            min_players: 4,
            sym: 'D',
          },          {
            name: 'E',
            value: 240,
            revenue: 25,
            desc: 'The purchaser of this private company receives a share of '\
                  'the T&P Railroad.',
            abilities: [{ type: 'shares', shares: 'T&P_2' }],
            min_players: 5,
            sym: 'E',
          }
        ].freeze

        CORPORATIONS = [
         {
           float_percent: 50,
           sym: 'T&P',
           name: 'Texas and Pacific Railway',
           logo: '18_texas/TP',
           tokens: [0, 0, 0, 0, 0],
           city: 0,
           coordinates: 'D9',
           color: 'darkmagenta',
           text_color: 'white',
           reservation_color: nil,
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'MKT',
           name: 'Missouri–Kansas–Texas Railway',
           logo: '18_texas/MKT',
           tokens: [0, 0, 0, 0],
           coordinates: 'B11',
           color: 'green',
           text_color: 'white',
           reservation_color: nil,
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'SP',
           name: 'Southern Pacific Railroad',
           logo: '18_texas/SP',
           tokens: [0, 0, 0, 0, 0],
           coordinates: 'I14',
           color: 'orange',
           text_color: 'white',
           reservation_color: nil,
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'MP',
           name: 'Missouri Pacific Railroad',
           logo: '18_texas/MP',
           tokens: [0, 0, 0, 0],
           coordinates: 'G10',
           color: 'red',
           text_color: 'white',
           reservation_color: nil,
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'SSW',
           name: 'St. Louis Southwestern Railway',
           logo: '18_texas/SSW',
           tokens: [0, 0, 0],
           coordinates: 'D15',
           color: 'mediumpurple',
           text_color: 'white',
           reservation_color: nil,
           always_market_price: true,
         },
         {
           float_percent: 50,
           sym: 'SAA',
           name: 'San Antonio and Aransas Pass',
           logo: '18_texas/SAA',
           tokens: [0, 0, 0],
           coordinates: 'J5',
           color: 'black',
           text_color: 'white',
           reservation_color: nil,
           always_market_price: true,
         },
       ].freeze

        LOCATION_NAMES = {
          'A12' => 'Oklahoma City',
          'A18' => 'Little Rock',
          'B11' => 'Denison',
          'C16' => 'Texarkana',
          'D1' => 'El Paso',
          'D9' => 'Fort Worth & Dallas',
          'D15' => 'Marshall',
          'D19' => 'Shreveport',
          'E4' => 'Cisco',
          'F9' => 'Waco',
          'F13' => 'Palestine',
          'F15' => 'Lufkin',
          'G10' => 'College Station',
          'H7' => 'Austin',
          'H19' => 'Lafayette',
          'I14' => 'Houston',
          'J1' => 'Piedras Negras',
          'J5' => 'San Antonio',
          'J15' => 'Galveston',
          'K10' => 'Victoria',
          'M2' => 'Laredo',
          'M8' => 'Corpus Christi',
          'N1' => 'Monterrey',
        }.freeze

        HEXES = {
          white: {
            %w[
            B9
            B13
            B15
            B17
            B19
            C8
            C10
            C12
            C14
            C18
            D7
            D11
            D13
            D17
            E6
            E8
            E10
            E12
            E14
            E16
            E18
            F7
            F11
            G6
            G8
            G12
            G18
            H9
            H11
            H13
            H15
            H17
            I6
            I8
            I10
            I16
            I18
            J7
            J9
            J11
            J13
            K2
            K4
            K6
            K8
            L1
            L3
            L5
            L7
            M4
            M6
            N3
            N5
            ] => '',
            %w[
            F17
            G14
            G16
            K12
            L9
            ] =>
            'upgrade=cost:40,terrain:water',
            %w[
            D3
            D5
            E2
            F3
            F5
            G2
            G4
            H3
            H5
            I2
            I4
            J3
            ] =>
            'upgrade=cost:40,terrain:desert',

            ['E4'] => 'city=revenue:0;upgrade=cost:40,terrain:desert',
            %w[B11
               F13
               C16
               D15
               F9
               G10
               K10
               M2] => 'city=revenue:0',
            ['F15'] => 'city=revenue:0;upgrade=cost:40,terrain:water',

            %w[
               H7
               J5
              ] => 'city=revenue:0;label=Y',
          },
          red: {
            ['A12'] => 'offboard=revenue:yellow_20|brown_40;path=a:0,b:_0;path=a:5,b:_0',
            ['A18'] => 'offboard=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:5,b:_0',
            ['D1'] => 'offboard=revenue:yellow_50|brown_80;path=a:4,b:_0;path=a:5,b:_0',
            ['D19'] => 'offboard=revenue:yellow_20|brown_40;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            ['H19'] => 'offboard=revenue:yellow_30|brown_50;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0',
            ['J1'] => 'offboard=revenue:yellow_30|brown_50;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['N1'] => 'offboard=revenue:yellow_60|brown_80;path=a:3,b:_0;path=a:4,b:_0',
          },
          gray: {
            ['J15'] => 'town=revenue:yellow_20|brown_50;path=a:1,b:_0;path=a:2,b:_0',
            ['M8'] => 'town=revenue:yellow_30|brown_50;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0',
          },
          yellow: {
            ['D9'] => 'city=revenue:30;city=revenue:30;label=Y;path=a:1,b:_0;path=a:_0,b:_1;path=a:_1,b:3',

            ['I14'] => 'city=revenue:30;label=Y;path=a:1,b:_0;path=a:5,b:_0',
            %w[I12] => 'path=a:1,b:4',
          },
        }.freeze

        def setup
          # Distribute privates
          # Rules call for randomizing privates, assigning to players then reordering players
          # based on worth of private
          # Instead, just pass out privates from least to most expensive since player order is already
          # random
          sorted_companies = @companies.sort_by(&:value)
          @players.each_with_index do |player, idx|

            company = sorted_companies.shift
            @log << "#{player.name} receives #{company.name} and pays #{format_currency(company.value)}"
            player.spend(company.value, @bank)
            player.companies << company
            company.owner = player if idx <= players.size
            after_buy_company(player, company, company.value)
          end
        end

        def new_auction_round
          Round::Auction.new(self, [
            Step::CompanyPendingPar,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G18Texas::Step::CompanyPendingPar,
            Engine::Step::BuySellParShares,
          ])
        end

        def status_array(corp)
          return if corp.floated?

          [["Token Fee: #{format_currency(TOKEN_FEE[corp.id])}"]]
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18Texas::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            G18Texas::Step::IssueShares,
          ], round_num: round_num)
        end

        def float_corporation(corporation)
          @log << "#{corporation.name} floats"
          stock_market.move_up(corporation)
          @log << "#{corporation.name} share value moves up one space to #{corporation.share_price.price}"
          fee = TOKEN_FEE[corporation.id]
          corporation.spend(fee, @bank)
          @log << "#{corporation.name} spends #{format_currency(fee)} for tokens"
        end

        def issuable_shares(entity)
          return [] unless entity.operating_history.size > 1
          return [] unless entity.corporation?

          bundles_for_corporation(entity, entity)
            .select { |bundle| @share_pool.fit_in_bank?(bundle) }
        end

        def redeemable_shares(entity)
          return [] unless entity.corporation?

          bundles_for_corporation(share_pool, entity)
            .select { |bundle| fit_in_treasury?(entity, bundle) }
            .reject { |bundle| entity.cash < bundle.price }
        end

        def fit_in_treasury?(entity, bundle)
          (bundle.percent + entity.percent_of(bundle.corporation)) <= TREASURY_SHARE_LIMIT
        end

        def tile_lays(_entity)
          if @phase.available?('3')
            [{ lay: true, upgrade: true, cost: 0 }, { lay: :not_if_upgraded, upgrade: false }]
          else
            [{ lay: true, upgrade: true, cost: 0 }]
          end
        end
      end
    end
  end
end
