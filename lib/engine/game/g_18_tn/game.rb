# frozen_string_literal: true

require_relative 'meta'
require_relative 'share_pool'
require_relative '../base'
require_relative '../company_price_50_to_150_percent'

module Engine
  module Game
    module G18TN
      class Game < Game::Base
        include_meta(G18TN::Meta)

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 8000

        CERT_LIMIT = { 3 => 16, 4 => 12, 5 => 10 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 450, 5 => 360 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '3' => 2,
          '4' => 3,
          '5' => 3,
          '6' => 3,
          '7' => 4,
          '8' => 13,
          '9' => 12,
          '14' => 3,
          '15' => 3,
          '16' => 1,
          '17' => 1,
          '18' => 1,
          '19' => 1,
          '20' => 2,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '28' => 2,
          '29' => 2,
          '39' => 2,
          '40' => 2,
          '41' => 3,
          '42' => 3,
          '43' => 2,
          '44' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 2,
          '57' => 4,
          '58' => 4,
          '63' => 4,
          '70' => 1,
          '141' => 2,
          '142' => 2,
          '143' => 1,
          '144' => 1,
          '145' => 2,
          '146' => 2,
          '147' => 2,
          '170' => 2,
          '619' => 2,
          'TN1' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' =>
            'city=revenue:40,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:5,b:_0;label=C',
          },
          'TN2' =>
          {
            'count' => 1,
            'color' => 'green',
            'code' => 'city=revenue:40,slots:2;path=a:1,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
                      'path=a:5,b:_0;path=a:0,b:_0;label=N',
          },
          'TN3' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' => 'city=revenue:60,slots:3;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;'\
                      'path=a:4,b:_0;path=a:5,b:_0;path=a:0,b:_0;label=P',
          },
        }.freeze

        LOCATION_NAMES = {
          'A16' => 'Cincinnati',
          'C4' => 'St. Louis',
          'E22' => 'Bristol Coalfields',
          'H1' => 'Little Rock',
          'J5' => 'Gulf Coast',
          'J17' => 'Atlanta',
          'B13' => 'Louisville',
          'B17' => 'Lexington',
          'C16' => 'Danville',
          'D7' => 'Paducah',
          'D11' => 'Bowling Green',
          'E10' => 'Clarksville',
          'F5' => 'Dyersburg',
          'F11' => 'Nashville',
          'F13' => 'Lebanon',
          'F17' => 'Knoxville',
          'G6' => 'Jackson',
          'G12' => 'Murfreesboro',
          'H3' => 'Memphis',
          'H7' => 'Corinth',
          'H15' => 'Chattanooga',
          'I10' => 'Huntsville',
          'J11' => 'Birmingham',
        }.freeze

        MARKET = [
          %w[60
             70
             80
             90
             100
             110
             120
             130
             150
             170
             190
             210
             230
             250
             275
             300e],
          %w[55
             60
             70
             80
             90p
             100
             110
             120
             130
             150
             170
             190
             210
             230
             250],
          %w[50
             55
             60
             70p
             80p
             90
             100
             110
             120
             130
             150
             170],
          %w[45y 50y 55 65p 75p 80 90 100],
          %w[40o 45y 50y 60 70 75 80],
          %w[35o 40o 45y 55y 65y],
          %w[25o 30o 40o 50y 60y],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            status: %w[can_buy_companies_from_other_players
                       can_buy_companies_operation_round_one
                       limited_train_buy],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            status: %w[can_buy_companies_from_other_players
                       can_buy_companies
                       limited_train_buy],
            operating_rounds: 2,
          },
          {
            name: '3½',
            on: "3'",
            train_limit: 4,
            tiles: %i[yellow green],
            status: %w[can_buy_companies_from_other_players
                       can_buy_companies
                       limited_train_buy],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            status: %w[can_buy_companies_from_other_players can_buy_companies],
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
            name: '6½',
            on: "6'",
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

        TRAINS = [{ name: '2', distance: 2, price: 80, rusts_on: '4', num: 5 },
                  { name: '3', distance: 3, price: 180, rusts_on: '6', num: 3 },
                  {
                    name: "3'",
                    distance: 3,
                    price: 180,
                    rusts_on: '6',
                    num: 2,
                    events: [{ 'type' => 'civil_war' }],
                  },
                  { name: '4', distance: 4, price: 300, obsolete_on: "6'", num: 3 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    num: 2,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  { name: '6', distance: 6, price: 600, num: 1 },
                  { name: "6'", distance: 6, price: 600, num: 1 },
                  { name: '8', distance: 8, price: 700, num: 7 }].freeze

        COMPANIES = [
          {
            sym: 'TCC',
            name: 'Tennessee Copper Co.',
            value: 20,
            revenue: 5,
            desc: 'Corporation owner may lay a free yellow tile in H17. It need not be '\
                  'connected to an existing station token of the corporation. It does not '\
                  'count toward the corporation\'s normal limit of two yellow tile lays per turn.',
            abilities: [
            {
              type: 'tile_lay',
              free: true,
              count: 1,
              owner_type: 'corporation',
              hexes: ['H17'],
              tiles: %w[7 8 9],
              when: 'track',
            },
          ],
          },
          {
            sym: 'ETWCR',
            name: 'East Tennessee & Western Carolina Railroad',
            value: 40,
            revenue: 10,
            desc: 'Corporation owner may lay a free yellow tile in F19. It need not be connected '\
                  'to an existing station token of the corporation. It does not count toward the '\
                  'corporation\'s normal limit of two yellow tile lays per turn.',
            abilities: [
              {
                type: 'tile_lay',
                free: true,
                count: 1,
                owner_type: 'corporation',
                hexes: ['F19'],
                tiles: %w[7 8 9],
                when: 'track',
              },
            ],
          },
          {
            sym: 'MCR',
            name: 'Memphis & Charleston Railroad',
            value: 70,
            revenue: 15,
            desc: 'Corporation owner may lay a free yellow tile in H3. It need not be connected '\
                  'to an existing station token of the corporation. It does not count toward the '\
                  'corporation\'s normal limit of two yellow tile lays per turn.',
            abilities: [
              {
                type: 'tile_lay',
                free: true,
                count: 1,
                owner_type: 'corporation',
                hexes: ['H3'],
                tiles: %w[5 6 57],
                when: 'track',
              },
            ],
          },
          {
            sym: 'OWR',
            name: 'Oneida & Western Railroad',
            value: 100,
            revenue: 20,
            desc: 'Corporation owner may lay a free yellow tile in E16. It need not be connected '\
                  'to an existing station token of the corporation. It does not count toward the '\
                  'corporation\'s normal limit of two yellow tile lays per turn.',
            abilities: [
              {
                type: 'tile_lay',
                free: true,
                count: 1,
                owner_type: 'corporation',
                hexes: ['E16'],
                tiles: %w[7 8 9],
                when: 'track',
              },
            ],
          },
          {
            sym: 'LNR',
            name: 'Louisville and Nashville Railroad',
            value: 175,
            revenue: 0,
            desc: 'The purchaser of this private company receives the president\'s certificate of '\
                  'the L&N Railroad and must immediately set its par value. The L&N automatically '\
                  'floats once this private company is purchased and is an exception to the normal '\
                  'rule. This private company closes immediately after the par value is set.',
            abilities: [{ type: 'shares', shares: 'L&N_0' }],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'SR',
            name: 'Southern Railway',
            logo: '18_tn/SR',
            simple_logo: '18_tn/SR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'F17',
            color: 'yellow',
            text_color: 'green',
          },
          {
            sym: 'GMO',
            name: 'Gulf, Mobile, and Ohio Railroad',
            logo: '18_tn/GMO',
            simple_logo: '18_tn/GMO.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G6',
            color: 'red',
          },
          {
            float_percent: 20,
            sym: 'L&N',
            name: 'Louisville and Nashville Railroad',
            logo: '18_tn/LN',
            simple_logo: '18_tn/LN.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'B13',
            color: 'blue',
          },
          {
            sym: 'IC',
            name: 'Illinois Central Railroad',
            logo: '18_tn/IC',
            simple_logo: '18_tn/IC.alt',
            tokens: [0, 40, 100],
            coordinates: 'D7',
            color: 'green',
          },
          {
            sym: 'NC&StL',
            name: 'Nashville, Chattanooga, and St. Louis Railroad',
            logo: '18_tn/NCS',
            simple_logo: '18_tn/NCS.alt',
            tokens: [0, 40],
            coordinates: 'H15',
            color: 'orange',
            text_color: 'black',
          },
          {
            sym: 'TC',
            name: 'Tennessee Central Railway',
            logo: '18_tn/TC',
            simple_logo: '18_tn/TC.alt',
            tokens: [0, 40],
            coordinates: 'F11',
            color: 'black',
          },
        ].freeze

        HEXES = {
          red: {
            ['A16'] => 'offboard=revenue:yellow_50|brown_80;path=a:5,b:_0;path=a:0,b:_0',
            ['C4'] => 'offboard=revenue:yellow_40|brown_60;path=a:4,b:_0;path=a:5,b:_0',
            ['E22'] => 'offboard=revenue:yellow_60|brown_40;path=a:1,b:_0;path=a:0,b:_0',
            ['H1'] =>
                   'offboard=revenue:yellow_20|brown_40;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
            ['J5'] => 'offboard=revenue:yellow_30|brown_50;path=a:2,b:_0;path=a:3,b:_0',
            ['J17'] => 'offboard=revenue:yellow_40|brown_60;path=a:1,b:_0;path=a:2,b:_0',
          },
          gray: {
            ['B13'] => 'city=revenue:30,loc:2;path=a:0,b:_0;path=a:4,b:_0;path=a:0,b:4',
            ['J11'] =>
            'town=revenue:yellow_30|brown_40;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0',
          },
          white: {
            %w[B17 G12] => 'city=revenue:0',
            %w[C16 E10 F5 F13] => 'town=revenue:0',
            %w[D7 F11 F17 H7] => 'city=revenue:0;upgrade=cost:40,terrain:water',
            %w[B15
               C14
               C18
               D15
               D19
               F15
               G14
               H11
               H13
               I14
               I16
               J13] => 'upgrade=cost:60,terrain:mountain',
            ['E16'] => 'upgrade=cost:60,terrain:mountain;icon=image:18_tn/owr',
            %w[F21 G18 G20] => 'upgrade=cost:120,terrain:mountain',
            ['F19'] => 'upgrade=cost:120,terrain:mountain;icon=image:18_tn/etwcr',
            ['H17'] => 'upgrade=cost:120,terrain:mountain;icon=image:18_tn/tcc',
            ['H3'] => 'city=revenue:0;upgrade=cost:60,terrain:water;icon=image:18_tn/mcr',
            ['I10'] => 'town=revenue:0;upgrade=cost:40,terrain:water',
            %w[C8 E8 F9 G8 H9 I12 G16] =>
            'upgrade=cost:40,terrain:water',
            %w[D5 E4 F3 G2] => 'upgrade=cost:60,terrain:water',
            %w[C6
               D9
               D13
               D17
               E6
               E12
               E14
               E18
               E20
               F7
               G4
               G10
               H5
               I2
               I4
               I6
               I8
               J15] => '',
          },
          yellow: {
            ['C12'] => 'path=a:0,b:3',
            ['D11'] => 'town=revenue:10;path=a:0,b:_0;path=a:_0,b:3',
            ['G6'] => 'city=revenue:20;path=a:3,b:_0;path=a:5,b:_0',
            ['H15'] => 'city=revenue:20;path=a:1,b:_0;path=a:5,b:_0;label=C',
          },
        }.freeze

        LAYOUT = :pointy

        GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_companies_operation_round_one' =>
            ['Can Buy Companies OR 1', 'Corporations can buy companies for face value in OR 1'],
        ).merge(
          'can_buy_companies_from_other_players' =>
            ['Interplayer Company Buy', 'Companies can be bought between players']
        ).merge(
          Engine::Step::SingleDepotTrainBuy::STATUS_TEXT
        ).freeze

        # Two lays or one upgrade
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

        HEX_WITH_P_LABEL = %w[F11 H3 H15].freeze
        STANDARD_YELLOW_CITY_TILES = %w[5 6 57].freeze
        GREEN_CITY_TILES = %w[14 15 619 TN1 TN2].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'civil_war' => ['Civil War', 'Companies with trains lose revenue of one train its next OR']
        ).freeze

        include CompanyPrice50To150Percent

        def setup
          setup_company_price_50_to_150_percent

          # Illinois Central has a 30% presidency share
          ic = @corporations.find { |c| c.id == 'IC' }
          presidents_share = ic.shares_by_corporation[ic].first
          presidents_share.percent = 30
          final_share = ic.shares_by_corporation[ic].last
          @share_pool.transfer_shares(final_share.to_bundle, @bank)

          @brown_p_tile ||= @tiles.find { |t| t.name == '170' }
          @green_nashville_tile ||= @tiles.find { |t| t.name == 'TN2' }
        end

        def status_str(corp)
          return unless corp.id == 'IC'

          "#{corp.presidents_percent}% President's Share"
        end

        def operating_round(round_num)
          # For OR 1, set company buy price to face value only
          if @turn == 1
            @companies.each do |company|
              company.min_price = company.value
              company.max_price = company.value
            end
          end

          # After OR 1, the company buy price is changed to 50%-150%
          setup_company_price_50_to_150_percent if @turn == 2 && round_num == 1

          Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::SpecialTrack,
            G18TN::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G18TN::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::SingleDepotTrainBuy,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::BuySellParShares,
          ])
        end

        def routes_revenue(routes)
          total_revenue = super

          corporation = routes.first&.corporation

          return total_revenue if !abilities(corporation, :civil_war) || routes.size < corporation.trains.size

          # The train with the lowest revenue loses the income due to the war effort
          total_revenue - routes.map(&:revenue).min
        end

        def init_share_pool
          G18TN::SharePool.new(self)
        end

        def purchasable_companies(entity = nil)
          candidates = @companies.select do |company|
            company.owner&.player? && company.owner != entity
          end

          candidates.reject! { |c| @round.company_sellers.value?(c.owner) } if allowed_to_buy_during_operation_round_one?
          candidates
        end

        def allowed_to_buy_during_operation_round_one?
          @turn == 1 &&
            @round.is_a?(Round::Operating) &&
            @phase.status.include?('can_buy_companies_operation_round_one')
        end

        def event_civil_war!
          @log << '-- Event: Civil War! --'

          # Corporations that are active and own trains does get a Civil War token.
          # The current entity might not have any, but the 3' train it bought that
          # triggered the Civil War will be part of the trains for it.
          # There is a possibility that the trains will not have a valid route but
          # that is handled in the route code.
          corps = @corporations.select do |c|
            (c == current_entity) || (c.floated? && c.trains.any?)
          end

          corps.each do |corp|
            corp.add_ability(Engine::Ability::Base.new(
              type: :civil_war,
              description: 'Civil War! (One time effect)',
              count: 1,
            ))
          end

          @log << "#{corps.map(&:name).sort.join(', ')} each receive a Civil War token which affects their next OR"
        end

        def lnr
          @lnr ||= company_by_id('LNR')
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil, laying_entity: nil)
          # When upgrading from green to brown:
          #   If Memphis (H3), Chattanooga (H15), Nashville (F11)
          #   only brown P tile (#170) are allowed.
          return to.name == '170' if from.color == :green && HEX_WITH_P_LABEL.include?(from.hex.name)

          # When upgrading Nashville (F11) from yellow to green, only TN2 from green to brown:
          return to.name == 'TN2' if from.color == :yellow && from.hex.name == 'F11'

          super
        end

        def all_potential_upgrades(tile, tile_manifest: false, selected_company: nil, laying_entity: nil)
          upgrades = super

          return upgrades unless tile_manifest

          # Tile manifest for yellow standard cities should show N tile (TN1) as an option
          upgrades |= [@green_nashville_tile] if green_nashville_upgrade?(tile)

          # Tile manifest for green cities should show P tile as an option
          upgrades |= [@brown_p_tile] if @brown_p_tile && GREEN_CITY_TILES.include?(tile.name)

          upgrades
        end

        def green_nashville_upgrade?(tile)
          @green_nashville_tile && STANDARD_YELLOW_CITY_TILES.include?(tile.name)
        end
      end
    end
  end
end
