# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative '../company_price_50_to_150_percent'

module Engine
  module Game
    module G18MS
      class Game < Game::Base
        include_meta(G18MS::Meta)

        attr_accessor :chattanooga_reached

        CURRENCY_FORMAT_STR = '$%d'

        BANK_CASH = 10_000

        CERT_LIMIT = { 2 => 20, 3 => 14, 4 => 10 }.freeze

        STARTING_CASH = { 2 => 900, 3 => 625, 4 => 525 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        TILES = {
          '3' => 3,
          '4' => 3,
          '5' => 2,
          '6' => 3,
          '7' => 4,
          '8' => 10,
          '9' => 10,
          '57' => 3,
          '58' => 3,
          '14' => 3,
          '15' => 3,
          '16' => 1,
          '19' => 1,
          '20' => 1,
          '23' => 4,
          '24' => 4,
          '25' => 2,
          '26' => 1,
          '27' => 1,
          '28' => 1,
          '29' => 1,
          '87' => 2,
          '88' => 2,
          '143' => 2,
          '204' => 2,
          '619' => 3,
          '39' => 1,
          '40' => 2,
          '41' => 2,
          '42' => 2,
          '43' => 1,
          '45' => 1,
          '46' => 1,
          '47' => 2,
          '63' => 4,
          '446' =>
          {
            'count' => 1,
            'color' => 'gray',
            'code' =>
            'city=revenue:70,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;path=a:4,b:_0;'\
              'path=a:5,b:_0;label=BM',
          },
          'X31b' =>
          {
            'count' => 1,
            'color' => 'brown',
            'code' =>
            'city=revenue:50,slots:3;path=a:0,b:_0;path=a:1,b:_0;path=a:2,b:_0;path=a:3,b:_0;label=Mob',
          },
        }.freeze

        LOCATION_NAMES = {
          'A1' => 'Memphis',
          'B2' => 'Grenada',
          'B12' => 'Chattanooga',
          'C5' => 'Starkville',
          'C7' => 'Tuscaloosa',
          'C9' => 'Birmingham',
          'D6' => 'York',
          'E1' => 'Jackson',
          'E5' => 'Meridian',
          'E9' => 'Selma',
          'E11' => 'Montgomery',
          'E15' => 'Atlanta',
          'G3' => 'Hattiesburg',
          'H4' => 'Gulfport',
          'H6' => 'Mobile',
          'H8' => 'Pensacola',
          'H10' => 'Tallahassee',
          'I1' => 'New Orleans',
        }.freeze

        MARKET = [
          %w[65y
             70
             75
             80
             90p
             100
             110
             130
             150
             170
             200
             230
             265
             300],
          %w[60y
             65y
             70p
             75p
             80p
             90
             100
             110
             130
             150
             170
             200
             230
             265],
          %w[50y 60y 65y 70 75 80 90 100 110 130 150],
          %w[45y 50y 60y 65y 70 75 80],
          %w[40y 45y 50y 60y],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 3,
            tiles: [:yellow],
            operating_rounds: 2,
            status: ['can_buy_companies_operation_round_one'],
          },
          {
            name: '3',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: ['can_buy_companies'],
          },
          {
            name: '6',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: 'D',
            train_limit: 3,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 80,
            num: 5,
          },
          {
            name: '3+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 180,
            num: 4,
          },
          {
            name: '4+',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 300,
            num: 3,
          },
          { name: '5', distance: 5, price: 500, num: 2 },
          {
            name: '6',
            distance: 6,
            price: 550,
            num: 2,
            events: [{ 'type' => 'close_companies' }, { 'type' => 'remove_tokens' }],
          },
          {
            name: '2D',
            distance: 2,
            multiplier: 2,
            price: 500,
            num: 4,
            available_on: '6',
            variants: [
              {
                name: '4D',
                price: 750,
                multiplier: 2,
                available_on: '6',
                distance: 4,
              },
            ],
          },
          {
            name: '5D',
            multiplier: 2,
            distance: 5,
            price: 850,
            num: 1,
            available_on: '6',
          },
        ].freeze

        COMPANIES = [
          {
            name: 'Alabama Great Southern Railroad',
            value: 30,
            revenue: 15,
            desc: 'The owning Major Corporation may lay an extra yellow tile for free. '\
              'This extra tile must extend existing track and could be used to extend from a yellow or green tile '\
              "played as a Major Corporation's normal tile lay. This ability can only be used once, and using it "\
              'does not close the Private Company. Alabama Great Southern Railroad can be bought for exactly face '\
              'value during OR 1 by an operating Major Corporation if the president owns the Private Company.',
            sym: 'AGS',
            abilities: [
            {
              type: 'tile_lay',
              owner_type: 'corporation',
              count: 1,
              free: true,
              special: false,
              reachable: true,
              hexes: [],
              tiles: [],
              when: %w[track owning_corp_or_turn],
            },
          ],
          },
          {
            name: 'Birmingham Southern Railroad',
            value: 40,
            revenue: 10,
            desc: 'The owning Major Corporation may lay one or two extra yellow tiles for free. This extra tile lay '\
              'must extend existing track and could be used to extend from a yellow or green tile played as a '\
              "corporation's normal tile lay. This ability can only be used once during a single operating round, and"\
              ' using it does not close the Private Company. Birmingham Southern Railroad can be bought for exactly '\
              'face value during OR 1 by an operating Major Corporation if the president owns the Private Company.',
            sym: 'BS',
            abilities: [
              {
                type: 'tile_lay',
                owner_type: 'corporation',
                count: 2,
                free: true,
                special: false,
                reachable: true,
                must_lay_together: true,
                hexes: [],
                tiles: [],
                when: %w[track owning_corp_or_turn],
              },
            ],
          },
          {
            name: 'Meridian and Memphis Railway',
            value: 50,
            revenue: 15,
            desc: 'The owning Major Corporation may lay their cheapest available token for half price. '\
              'This is not an extra token placement. This ability can only be used once, '\
              'and using it does not close the Private Company.',
            sym: 'M&M',
            abilities: [
              {
                type: 'token',
                owner_type: 'corporation',
                hexes: [],
                discount: 0.5,
                count: 1,
                from_owner: true,
              },
            ],
          },
          {
            name: 'Mississippi Central Railway',
            value: 60,
            revenue: 5,
            desc: 'The owning Major Corporation exchanges this private for a special 2+ train when purchased. '\
              '(This 2+ train may not be sold.) This exchange occurs immediately when purchased. '\
              'If this exchange would place the Major Corporation over the train limit of 3, '\
              'the purchase is not allowed. If this Private Company is not purchased by the end of OR 4, '\
              "it may not be sold to a Major Corporation and counts against the owner's certificate limit until "\
              'it closes upon the start of Phase 6.',
            sym: 'MC',
          },
          {
            name: 'Mobile & Ohio Railway',
            value: 70,
            revenue: 5,
            desc: 'The owning Major Corporation may purchase an available 3+ Train or 4+ Train from the bank for a '\
              'discount of $100. Using this discount closes this Private Company. The discounted purchase is subject '\
              'to the normal rules governing train purchases - only during the train-buying step and train limits '\
              'apply.',
            sym: 'M&O',
            abilities: [
              {
                type: 'train_discount',
                discount: 100,
                owner_type: 'corporation',
                trains: ['3+', '4+'],
                count: 1,
                when: 'buying_train',
              },
            ],
          },
        ].freeze

        CORPORATIONS = [
          {
            float_percent: 60,
            max_ownership_percent: 70,
            sym: 'GMO',
            name: 'Gulf, Mobile and Ohio Railroad',
            logo: '18_ms/GMO',
            simple_logo: '18_ms/GMO.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'H6',
            color: 'black',
          },
          {
            float_percent: 60,
            max_ownership_percent: 70,
            sym: 'IC',
            name: 'Illinois Central Railroad',
            logo: '18_ms/IC',
            simple_logo: '18_ms/IC.alt',
            tokens: [0, 40, 100],
            coordinates: 'A1',
            color: '#397641',
          },
          {
            float_percent: 60,
            max_ownership_percent: 70,
            sym: 'L&N',
            name: 'Louisville and Nashville Railroad',
            logo: '18_ms/LN',
            simple_logo: '18_ms/LN.alt',
            tokens: [0, 40, 100],
            coordinates: 'C9',
            color: '#0d5ba5',
          },
          {
            float_percent: 60,
            max_ownership_percent: 70,
            sym: 'Fr',
            name: 'Frisco',
            logo: '18_ms/Fr',
            simple_logo: '18_ms/Fr.alt',
            tokens: [0, 40, 100],
            coordinates: 'E1',
            color: '#ed1c24',
          },
          {
            float_percent: 60,
            max_ownership_percent: 70,
            sym: 'WRA',
            name: 'Western Railway of Alabama',
            logo: '18_ms/WRA',
            simple_logo: '18_ms/WRA.alt',
            tokens: [0, 40, 100],
            coordinates: 'E11',
            color: '#c7c4e2',
            text_color: 'black',
          },
        ].freeze

        HEXES = {
          empty: { ['B14'] => '' },
          white: {
            %w[B4
               B6
               B8
               B10
               C1
               C3
               C11
               D2
               D4
               D8
               D10
               E3
               F4
               F10
               G5
               G9
               G11] => '',
            %w[E7 F2 F6 F8 G1 G7] => 'upgrade=cost:20,terrain:water',
            ['H2'] => 'upgrade=cost:40,terrain:water',
            ['H8'] => 'town=revenue:0;upgrade=cost:20,terrain:water',
            %w[C7 C9 E5 E9 E11 H6] => 'city=revenue:0',
            %w[B2 C5 D6 G3 H4] => 'town=revenue:0',
          },
          red: {
            ['B12'] =>
                     'offboard=revenue:yellow_40|brown_60;path=a:1,b:_0;icon=image:18_ms/coins',
            ['H10'] => 'offboard=revenue:yellow_30|brown_50;path=a:1,b:_0',
            ['A1'] =>
            'city=revenue:yellow_40|brown_50;path=a:5,b:_0;path=a:4,b:_0;border=edge:4',
            ['I1'] =>
            'city=revenue:yellow_50|brown_80,loc:center;town=revenue:10,loc:5.5;path=a:3,b:_0;path=a:_1,b:_0;'\
              'icon=image:18_ms/coins',
            ['A3'] => 'path=a:1,b:5;border=edge:1',
            ['D12'] => 'path=a:0,b:5;border=edge:5',
            ['E13'] =>
            'path=a:0,b:4;path=a:1,b:4;path=a:2,b:4;border=edge:0;border=edge:2;border=edge:4',
            ['F12'] => 'path=a:2,b:3;border=edge:3',
            ['E15'] => 'offboard=revenue:yellow_40|brown_50;path=a:1,b:_0;border=edge:1',
          },
          gray: { ['E1'] =>
            'city=revenue:yellow_30|brown_60,slots:2;path=a:3,b:_0;path=a:4,b:_0;path=a:5,b:_0',
   },
        }.freeze

        LAYOUT = :pointy

        # Game will end after 10 ORs (or 11 in case of optional rule) - checked in end_now? below
        GAME_END_CHECK = {}.freeze

        BANKRUPTCY_ALLOWED = false

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false # Emergency buy can buy any available trains
        EBUY_PRES_SWAP = false # Do not allow presidental swap during emergency buy
        EBUY_SELL_MORE_THAN_NEEDED = true # Allow to sell extra to force buy a more expensive train

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'can_buy_companies_operation_round_one' =>
            ['Can Buy Companies OR 1', 'Corporations can buy AGS/BS companies for face value in OR 1'],
        ).freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'remove_tokens' => ['Remove Tokens', 'New Orleans route bonus removed']
        ).freeze

        HEXES_FOR_GRAY_TILE = %w[C9 E11].freeze
        COMPANY_1_AND_2 = %w[AGS BS].freeze

        def p1_company
          @p1_company ||= company_by_id('AGS')
        end

        def p2_company
          @p2_company ||= company_by_id('BS')
        end

        def chattanooga_hex
          @chattanooga_hex ||= @hexes.find { |h| h.name == 'B12' }
        end

        include CompanyPrice50To150Percent

        def setup
          @chattanooga_reached = false
          setup_company_price_50_to_150_percent

          @mobile_city_brown ||= @tiles.find { |t| t.name == 'X31b' }
          @gray_tile ||= @tiles.find { |t| t.name == '446' }
          @recently_floated = []

          # The last 2+ train will be used as free train for a private
          # Store it in the company in the meantime
          neutral = Corporation.new(
            sym: 'N',
            name: 'Neutral',
            tokens: [],
          )
          neutral.owner = @bank
          @free_train = train_by_id('2+-4')
          @free_train.buyable = false
          buy_train(neutral, @free_train, :free)

          @or = 0
          @last_or = @optional_rules&.include?(:or_11) ? 11 : 10
          @three_or_round = false
        end

        def timeline
          @timeline ||= [
            'At the start of OR 2, phase 3 starts.',
            'After OR 4, all 2+ trains are rusted. Trains salvaged for $20 each.',
            'After OR 6, all 3+ trains are rusted. Trains salvaged for $30 each.',
            'After OR 8, all 4+ trains are rusted. Trains salvaged for $60 each.',
            "Game ends after OR #{@last_or}!",
          ].freeze
          @timeline
        end

        def new_operating_round(round_num = 1)
          @or += 1
          # For OR 1, set company buy price to face value only
          @companies.each do |company|
            company.min_price = company.value
            company.max_price = company.value
          end if @or == 1

          # When OR2 is to start setup company prices and switch to green phase
          if @or == 2
            setup_company_price_50_to_150_percent
            @phase.next!
          end

          # Need to take new loan if in debt after SR
          if round_num == 1
            @players.each do |p|
              next unless p.cash.negative?

              debt = -p.cash
              interest = (debt / 2.0).ceil
              p.spend(interest, @bank, check_cash: false)
              @log << "#{p.name} has to borrow another #{format_currency(interest)} as being in debt at end of SR"
            end
          end

          # In case of 11 ORs, the last set will be 3 ORs
          if @or == 9 && @optional_rules&.include?(:or_11)
            @operating_rounds = 3
            @three_or_round = true
          end

          super
        end

        def round_description(name, _round_num = nil)
          case name
          when 'Stock'
            super
          when 'Draft'
            name
          else # 'Operating'
            message = ''
            message += ' - Change to Phase 3 after OR 1' if @or == 1
            message += ' - 2+ trains rust after OR 4' if @or <= 4
            message += ' - 3+ trains rust after OR 6' if @or > 4 && @or <= 6
            message += ' - 4+ trains rust after OR 8' if @or > 6 && @or <= 8
            message += " - Game end after OR #{@last_or}" if @or > 8
            "#{name} Round #{@or} (of #{@last_or})#{message}"
          end
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Engine::Step::Exchange,
            G18MS::Step::SpecialTrack,
            G18MS::Step::SpecialToken,
            G18MS::Step::BuyCompany,
            G18MS::Step::Track,
            G18MS::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::SpecialBuyTrain,
            G18MS::Step::BuyTrain,
            [Engine::Step::BuyCompany, blocks: true],
          ], round_num: round_num)
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::BuySellParShares,
          ])
        end

        def init_round
          Round::Draft.new(self, [G18MS::Step::SimpleDraft], reverse_order: true)
        end

        def priority_deal_player
          return @players.first if @round.is_a?(Round::Draft)

          super
        end

        def or_round_finished
          @recently_floated = []

          # In case we get phase change during the last OR set we ensure we have 3 ORs
          @operating_rounds = 3 if @three_or_round
        end

        def or_set_finished
          case @turn
          when 3 then rust_all('2+', 20)
          when 4 then rust_all('3+', 30)
          when 5 then rust_all('4+', 60)
          end
        end

        def or_description_short(turn, round)
          ((turn - 1) * 2 + round).to_s
        end

        # Game will end directly after the end of OR 10
        def end_now?(_after)
          @or == @last_or
        end

        def purchasable_companies(entity = nil)
          entity ||= current_entity
          return [] if entity.company?

          # Only companies owned by the president may be bought
          # Allow MC to be bought only before OR 3.1 and there is room for a 2+ train
          companies = super.select { |c| c.owned_by?(entity.player) }
          companies.reject! { |c| c.id == 'MC' && (@turn >= 3 || entity.trains.size == train_limit(entity)) }

          return companies unless @phase.status.include?('can_buy_companies_operation_round_one')

          return [] if @turn > 1

          companies.select do |company|
            COMPANY_1_AND_2.include?(company.id)
          end
        end

        def revenue_for(route, stops)
          revenue = super

          abilities(route.corporation, :hexes_bonus) do |ability|
            revenue += stops.map { |s| s.hex.id }.uniq.sum { |id| ability.hexes.include?(id) ? ability.amount : 0 }
          end

          revenue
        end

        def routes_revenue(routes)
          active_step.current_entity.trains.each do |t|
            next unless t.name == "#{@turn}+"

            # Trains that are going to be salvaged at the end of this OR
            # cannot be sold when they have been run
            t.buyable = false unless @optional_rules&.include?(:allow_buy_rusting)
          end if @round.round_num == 2

          super
        end

        def event_remove_tokens!
          @corporations.each do |corporation|
            abilities(corporation, :hexes_bonus) do |a|
              bonus_hex = @hexes.find { |h| a.hexes.include?(h.name) }
              hex_name = bonus_hex.name
              corporation.remove_ability(a)

              @log << "Route bonus is removed from #{get_location_name(hex_name)} (#{hex_name})"
            end
          end
        end

        def upgrades_to?(from, to, _special = false)
          # Only allow tile gray tile (446) in Montgomery (E11) or Birmingham (C9)
          return to.name == '446' if from.color == :brown && HEXES_FOR_GRAY_TILE.include?(from.hex.name)

          # Only allow tile Mobile City brown tile in Mobile City hex (H6)
          return to.name == 'X31b' if from.color == :green && from.hex.name == 'H6'

          super
        end

        def all_potential_upgrades(tile, tile_manifest: false)
          upgrades = super

          return upgrades unless tile_manifest

          # Tile manifest for tile 15 should show brown Mobile City as a potential upgrade
          upgrades |= [@mobile_city_brown] if @mobile_city_brown && tile.name == '15'

          # Tile manifest for tile 63 should show 446 as a potential upgrade
          upgrades |= [@gray_tile] if @gray_tile && tile.name == '63'

          upgrades
        end

        def float_corporation(corporation)
          @recently_floated << corporation

          super
        end

        def tile_lays(entity)
          return super unless @recently_floated.include?(entity)

          [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
        end

        def add_free_train_and_close_company(corporation, company)
          @free_train.buyable = true
          buy_train(corporation, @free_train, :free)
          @free_train.buyable = false
          company.close!
          @log << "#{corporation.name} exchanges #{company.name} for a free non sellable #{@free_train.name} train"
        end

        def get_location_name(hex_name)
          @hexes.find { |h| h.name == hex_name }.location_name
        end

        def remove_icons(hex_to_clear)
          @hexes
            .select { |hex| hex_to_clear == hex.name }
            .each { |hex| hex.tile.icons = [] }
        end

        def president_assisted_buy(corporation, train, price)
          # Can only assist if corporation cannot afford the train, but can pay at least 50%.
          # Corporation also need to own at least one train, and the train need to be permanent.
          if corporation.trains.size.positive? &&
            !train.name.include?('+') &&
            corporation.cash >= price / 2 &&
            price > corporation.cash

            fee = 50
            president_assist = price - corporation.cash
            return [president_assist, fee] unless corporation.player.cash < president_assist + fee
          end

          super
        end

        def show_progress_bar?
          true
        end

        def progress_information
          base_progress = [
            { type: :PRE },
            { type: :SR },
            { type: :OR, name: '1' },
            { type: :OR, name: '2' },
            { type: :SR },
            { type: :OR, name: '3' },
            { type: :OR, name: '4', exportAfter: true, exportAfterValue: '2+' },
            { type: :SR },
            { type: :OR, name: '5' },
            { type: :OR, name: '6', exportAfter: true, exportAfterValue: '3+' },
            { type: :SR },
            { type: :OR, name: '7' },
            { type: :OR, name: '8', exportAfter: true, exportAfterValue: '4+' },
            { type: :SR },
            { type: :OR, name: '9' },
            { type: :OR, name: '10' },
          ]

          base_progress << { type: :OR, name: '11' } if @optional_rules&.include?(:or_11)
          base_progress << { type: :End }
        end

        private

        def rust_all(train, salvage)
          rusted_trains = trains.select { |t| !t.rusted && t.name == train }
          return if rusted_trains.empty?

          owners = Hash.new(0)
          rusted_trains.each do |t|
            if t.owner.corporation? && t.owner.full_name != 'Neutral'
              @bank.spend(salvage, t.owner)
              owners[t.owner.name] += 1
            end
            rust(t)
          end

          @log << "-- Event: #{rusted_trains.map(&:name).uniq} trains rust " \
            "( #{owners.map { |c, t| "#{c} x#{t}" }.join(', ')}) --"
          @log << "Corporations salvage #{format_currency(salvage)} from each rusted train"
        end
      end
    end
  end
end
