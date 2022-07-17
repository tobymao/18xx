# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative '../base'
require_relative '../../loan'

module Engine
  module Game
    module G1848
      class Game < Game::Base
        attr_reader :sydney_adelaide_connected, :boe, :private_closed_triggered

        include_meta(G1848::Meta)
        include Map

        CURRENCY_FORMAT_STR = '£%d'

        BANK_CASH = 10_000

        CERT_LIMIT = { 3 => 20, 4 => 17, 5 => 14, 6 => 12 }.freeze

        CERT_LIMIT_RECEIVERSHIP = {
          3 => { 1 => 18, 2 => 16, 3 => 14, 4 => 12, 5 => 10 },
          4 => { 1 => 15, 2 => 13, 3 => 11, 4 => 10, 5 => 9 },
          5 => { 1 => 13, 2 => 12, 3 => 10, 4 => 9, 5 => 8 },
          6 => { 1 => 11, 2 => 10, 3 => 9, 4 => 8, 5 => 7 },
        }.freeze

        CERT_LIMIT_RECEIVERSHIP_REDUCTION = { 3 => 2, 4 => 2, 5 => 1, 6 => 1 }.freeze

        STARTING_CASH = { 3 => 840, 4 => 630, 5 => 510, 6 => 430 }.freeze

        K_BONUS = { 0 => 0, 1 => 0, 2 => 50, 3 => 100, 4 => 150, 5 => 200 }.freeze

        BOE_STARTING_CASH = 2000

        BOE_STARTING_PRICE = 70

        BOE_ROW = 6

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        EBUY_PRES_SWAP = false

        MARKET = [
          %w[0c
             70
             80
             90
             100
             110
             120
             140
             160
             190
             220
             250
             280
             320
             360
             400
             450e],
          %w[0c
             60
             70
             80
             90
             100p
             110
             130
             150
             180
             210
             240
             270
             310
             350
             390
             440],
          %w[0c
             50
             60
             70
             80
             90p
             100
             120
             140
             170
             200
             230
             260
             300],
          %w[0c 40 50 60 70 80p 90 110 130 160 190],
          %w[0c 30 40 50 60 70p 80 100 120],
          %w[0c 20 30 40 50 60 70],
          %w[70r
             80r
             90r
             100r
             110r
             120r
             130r
             140r
             150r
             160r
             170r
             180r
             195r
             210r
             225r
             240r
             260e
             280r
             300r
             320r
             340r],
        ].freeze

        MARKET_TEXT = {
          par: 'Par value',
          repar: 'Bank of England share value',
          close: 'Receivership',
          endgame: 'End game trigger',
        }.freeze

        GAME_END_REASONS_TEXT = {
          bank: 'The bank runs out of money',
          stock_market: 'Corporation hit max stock value or Bank of England has given 16 or more loans',
          custom: 'Fifth corporation is in receivership',
        }.freeze

        GAME_END_CHECK = { bank: :full_or, stock_market: :full_or, custom: :full_or }.freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
                  },
                  {
                    name: '4',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                    status: ['can_buy_companies'],
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
                  }].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 6,
            variants: [
              { name: '2+', price: 120 },
            ],
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 200,
            rusts_on: '6',
            num: 5,
            variants: [
              { name: '3+', distance: 3, price: 230 },
            ],
            events: [{ 'type' => 'take_out_loans' },
                     { 'type' => 'lay_second_tile' }],
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 300,
            rusts_on: '8',
            num: 4,
            variants: [
              { name: '4+', distance: 4, price: 340 },
            ],
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 500,
            num: 3,
            variants: [
              { name: '5+', distance: 5, price: 550 },
],
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 600,
            num: 2,
            variants: [
              { name: '6+', distance: 6, price: 660 },
            ],
            events: [{ 'type' => 'com_operates' }],
          },
          {
            name: 'D',
            distance: 999,
            price: 1100,
            num: 6,
            discount: { '4' => 300, '5' => 300, '6' => 300 },
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 800,
            num: 6,
          },
          {
            name: '2E',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 99 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 200,
            num: 6,
            available_on: '5',
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
                  'take_out_loans' => ['Corporations can take out loans'],
                  'lay_second_tile' => ['Corporations can lay a second tile'],
                  'com_operates' =>
                  ['COM operates without Sydney-Adelaide connection'],
                ).freeze

        COMPANIES = [
          {
            sym: 'P1',
            name: "Melbourne & Hobson's Bay Railway Company",
            value: 40,
            discount: 10,
            min_price: 1,
            max_price: 40,
            revenue: 5,
            desc: 'No special abilities.',
          },
          {
            sym: 'P2',
            name: 'Sydney Railway Company',
            value: 80,
            min_price: 1,
            max_price: 80,
            discount: 10,
            revenue: 10,
            desc: 'Owning Public Company or its Director may build one (1) free tile on a desert hex (marked by'\
                  ' a cactus icon). This power does not go away after a 5/5+ train is purchased.',
            abilities: [
                    {
                      type: 'tile_lay',
                      discount: 40,
                      hexes: %w[B7 B9 C2 C4 C8 E6 E8],
                      tiles: %w[7 8 9],
                      count: 1,
                      reachable: true,
                      consume_tile_lay: true,
                      owner_type: 'corporation',
                      when: 'owning_corp_or_turn',
                    },
                    {
                      type: 'tile_lay',
                      discount: 40,
                      hexes: %w[B7 B9 C2 C4 C8 E6 E8],
                      tiles: %w[7 8 9],
                      count: 1,
                      reachable: true,
                      consume_tile_lay: true,
                      owner_type: 'player',
                      when: 'owning_player_or_turn',
                    },
                  ],
          },
          {
            sym: 'P3',
            name: 'Tasmanian Railways',
            value: 140,
            discount: 30,
            min_price: 1,
            max_price: 140,
            revenue: 15,
            desc: 'The Tasmania tile can be placed by a Public Company on one of the dark blue hexes. This is in'\
                  " addition to the company's normal build that turn.",
            abilities: [
                    {
                      type: 'tile_lay',
                      hexes: %w[I8 I10],
                      tiles: %w[241'],
                      owner_type: 'corporation',
                      when: 'owning_corp_or_turn',
                      special: true,
                      count: 1,
                      free: true,
                    },
                  ],

          },
          {
            sym: 'P4',
            name: 'The Ghan',
            value: 220,
            discount: 50,
            min_price: 1,
            max_price: 220,
            revenue: 20,
            desc: 'Owning Public Company or its Director may receive a one-time discount of £100 on the purchase'\
                  ' of a 2E (Ghan) train. This power does not go away after a 5/5+ train is purchased.',
            abilities: [
                    {
                      type: 'train_discount',
                      discount: 100,
                      trains: ['2E'],
                      count: 1,
                      owner_type: 'corporation',
                      when: 'buying_train',
                    },
                    {
                      type: 'train_discount',
                      discount: 100,
                      trains: ['2E'],
                      count: 1,
                      owner_type: 'player',
                      when: 'owning_player_or_turn',
                    },
                  ],

          },
          {
            sym: 'P5',
            name: 'Trans-Australian Railway',
            value: 0,
            discount: -170,
            revenue: 25,
            desc: 'The owner receives a 10% share in the QR. Cannot be bought by a corporation',
            abilities: [{ type: 'shares', shares: 'QR_1' },
                        { type: 'no_buy' }],
          },
          {
            sym: 'P6',
            name: 'North Australian Railway',
            value: 0,
            discount: -230,
            revenue: 30,
            desc: "The owner receives a Director's Share share in the CAR, which must start at a par value of £100."\
                  ' Cannot be bought by a corporation',
            abilities: [{ type: 'shares', shares: 'CAR_0' },
                        { type: 'no_buy' }],
          },
        ].freeze

        CORPORATIONS = [
          {
            sym: 'BOE',
            name: 'Bank of England',
            logo: '1848/BOE',
            simple_logo: '1848/BOE.alt',
            tokens: [],
            text_color: 'black',
            type: 'bank',
            shares: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
            color: 'antiqueWhite',
          },
          {
            sym: 'CAR',
            name: 'Central Australian Railway',
            logo: '1848/CAR',
            simple_logo: '1848/CAR.alt',
            tokens: [0, 40, 100],
            coordinates: 'E4',
            color: '#232b2b',
          },
          {
            sym: 'VR',
            name: 'Victorian Railways',
            logo: '1848/VR',
            simple_logo: '1848/VR.alt',
            tokens: [0, 40, 100],
            coordinates: 'H11',
            text_color: 'black',
            color: 'gold',
          },
          {
            sym: 'NSW',
            name: 'New South Wales Railways',
            logo: '1848/NSW',
            simple_logo: '1848/NSW.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'F17',
            text_color: 'black',
            color: 'orange',
          },
          {
            sym: 'SAR',
            name: 'South Australian Railway',
            logo: '1848/SAR',
            simple_logo: '1848/SAR.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G6',
            color: 'darkMagenta',
          },
          {
            sym: 'COM',
            name: 'Commonwealth Railways',
            logo: '1848/COM',
            simple_logo: '1848/COM.alt',
            tokens: [0, 0, 100, 100, 100],
            color: 'dimGray',
          },
          {
            sym: 'FT',
            name: 'Federal Territory Railway',
            logo: '1848/FT',
            simple_logo: '1848/FT.alt',
            tokens: [0, 40, 100, 100],
            coordinates: 'G14',
            color: 'mediumBlue',
          },
          {
            sym: 'WA',
            name: 'West Australian Railway',
            logo: '1848/WA',
            simple_logo: '1848/WA.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'D1',
            color: 'maroon',
          },
          {
            sym: 'QR',
            name: "Queensland Gov't Railway",
            logo: '1848/QR',
            simple_logo: '1848/QR.alt',
            tokens: [0, 40, 100, 100, 100],
            coordinates: 'B19',
            color: 'darkGreen',
          },
        ].freeze

        TILE_LAYS = [{ lay: true, upgrade: true }].freeze
        EXTRA_TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded }].freeze

        def tile_lays(_entity)
          @extra_tile_lay ? EXTRA_TILE_LAYS : TILE_LAYS
        end

        def event_lay_second_tile!
          @log << 'Corporations can now perform a second tile lay'
          @extra_tile_lay = true
        end

        def event_take_out_loans!
          @log << 'Corporations can now take out loans'
        end

        def event_close_companies!
          @log << '-- Event: Private companies close --'
          @private_closed_triggered = true
          @companies.each do |company|
            unused_ability = company.all_abilities.any? { |ability| ability.type != :no_buy && !ability.used? }
            if unused_ability
              # reduce revenue to 0, keep company around, can't be bought if owned by player
              company.revenue = 0
              no_buy = Engine::Ability::NoBuy.new(type: 'no_buy')
              company.add_ability(no_buy)
            else
              # close company
              @log << "#{company.name} closes"
              company.close!
            end
          end
        end

        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :down_block

        HOME_TOKEN_TIMING = :operate

        def setup
          @sydney_adelaide_connected = false

          @boe = @corporations.find { |c| c.type == :bank }
          @boe.ipoed = true
          @boe.ipo_shares.each do |share|
            @share_pool.transfer_shares(
              share.to_bundle,
              share_pool
            )
          end
          @boe.owner = @share_pool
          @boe.cash = BOE_STARTING_CASH
          @stock_market.set_par(@boe, lookup_boe_price(BOE_STARTING_PRICE))
          @extra_tile_lay = false
          @close_corp_count = 0
          @player_corp_close_count = Hash.new { |h, k| h[k] = 0 }
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1848::Step::DutchAuction,
          ])
        end

        def stock_round
          G1848::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G1848::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G1848::Round::Operating.new(self, [
            G1848::Step::Loan,
            G1848::Step::CashCrisis,
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            G1848::Step::SpecialTrack,
            Engine::Step::BuyCompany,
            G1848::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1848::Step::Dividend,
            Engine::Step::SpecialBuyTrain,
            G1848::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def init_stock_market
          G1848::StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES,
                                 multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        end

        def operating_order
          @corporations.select(&:floated?).sort.partition { |c| c.type == :bank }.flatten
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          return %w[5 6 57].include?(to.name) if (from.hex.tile.label.to_s == 'K') && (from.hex.tile.color == 'white')
          return ['241'].include?(to.name) if selected_company&.sym == 'P3'

          super
        end

        def tile_valid_for_phase?(tile, hex: nil, phase_color_cache: nil)
          # tile 241, tasmania  is valid in all phases
          return true if tile.name == '241'

          super
        end

        def sar
          # SAR is used for graph to find adelaide (to connect to sydney for starting COM)
          @sar ||= @corporations.find { |corporation| corporation.name == 'SAR' }
        end

        def sydney
          @sydney ||= hex_by_id('F17')
        end

        def adelaide
          @adelaide ||= hex_by_id('G6')
        end

        def check_sydney_adelaide_connected
          return @sydney_adelaide_connected if @sydney_adelaide_connected

          graph = Graph.new(self, home_as_token: true, no_blocking: true)
          graph.compute(sar)
          @sydney_adelaide_connected = graph.reachable_hexes(sar).include?(sydney)
          @sydney_adelaide_connected
        end

        def place_home_token(entity)
          return super if entity.name != :COM
          return unless @sydney_adelaide_connected
          return if entity.tokens.first&.used

          # COM places home tokens... regardless as to whether there is space for them
          [sydney, adelaide].each do |home_hex|
            city = home_hex.tile.cities[0]
            slot = city.available_slots.positive? ? 0 : city.slots
            home_token = entity.tokens.find { |token| !token.used && token.price.zero? }
            city.place_token(entity, home_token, free: true, check_tokenable: false, cheater: slot)
          end
        end

        def crowded_corps
          # 2E does not create a crowded corp
          @crowded_corps ||= (minors + corporations).select do |c|
            c.trains.count { |t| !t.obsolete && t.name != '2E' } > train_limit(c)
          end
        end

        def must_buy_train?(entity)
          # 2E does not count as compulsory train purchase
          entity.trains.reject { |t| t.name == '2E' }.empty? &&
            !depot.depot_trains.empty? &&
             (self.class::MUST_BUY_TRAIN == :route && @graph.route_info(entity)&.dig(:route_train_purchase))
        end

        # for 3 players corp share limit is 70%
        def corporation_opts
          @players.size == 3 ? { max_ownership_percent: 70 } : {}
        end

        def sell_shares_and_change_price(bundle, allow_president_change: true, swap: nil)
          super(bundle, allow_president_change: pres_change_ok?(bundle.corporation), swap: nil)
        end

        def pres_change_ok?(corporation)
          return false if corporation == @boe
        end

        def after_buy_company(player, company, _price)
          # share_price = 100
          # # NOTE: This should only ever be P6
          abilities(company, :shares) do |ability|
            ability.shares.each do |share|
              if share.president
                stock_market.set_par(share.corporation, stock_market.par_prices.find { |p| p.price == 100 })
                share_pool.buy_shares(player, share, exchange: :free)
                after_par(share.corporation)
              else
                share_pool.buy_shares(player, share, exchange: :free)
              end
              ability.use!
            end
          end
        end

        def lookup_boe_price(p)
          @stock_market.market[BOE_ROW].each do |sp|
            return sp if sp.price == p
          end
        end

        # loans

        def maximum_loans(entity)
          entity == @boe ? 20 : 5
        end

        def init_loans
          @loan_value = 100
          Array.new(20) { |id| Loan.new(id, @loan_value) }
        end

        def can_pay_interest?(_entity, _extra_cash = 0)
          false
        end

        def interest_owed(_entity)
          0
        end

        def market_share_limit(corporation = nil)
          return 100 if corporation == @boe

          MARKET_SHARE_LIMIT
        end

        def can_take_loan?(entity)
          entity.corporation? &&
            entity.loans.size < maximum_loans(entity) &&
            @loans.any?
        end

        def take_loan(entity, loan)
          raise GameError, "Cannot take more than #{maximum_loans(entity)} loans" unless can_take_loan?(entity)

          old_price = entity.share_price
          boe_old_price = @boe.share_price
          @boe.spend(loan.amount, entity)
          loan_taken_stock_market_movement(entity, loan)
          log_share_price(entity, old_price)
          log_share_price(@boe, boe_old_price)
          entity.loans << loan
          @boe.loans << loan
          @loans.delete(loan)
        end

        def loan_taken_stock_market_movement(entity, loan)
          @log << "#{entity.name} takes a loan and receives #{format_currency(loan.amount)}"
          2.times { @stock_market.move_left(entity) }
          @stock_market.move_right(boe)
        end

        # routing logic
        def visited_stops(route)
          modified_guage_changes = get_modified_guage_distance(route)
          added_stops = modified_guage_changes.positive? ? Array.new(modified_guage_changes) { Engine::Part::City.new('0') } : []
          super + added_stops
        end

        def get_modified_guage_distance(route)
          gauge_changes = edge_crossings(route)
          modifier = route.train.name.include?('+') ? 1 : 0
          gauge_changes - modifier
        end

        def edge_crossings(route)
          sum = route.paths.sum do |path|
            path.edges.sum do |edge|
              edge_is_a_border(edge) ? 1 : 0
            end
          end
          # edges are double counted
          sum / 2
        end

        def edge_is_a_border(edge)
          edge.hex.tile.borders.any? { |border| border.edge == edge.num }
        end

        def revenue_for(route, stops)
          k_sum = stops.count { |rl| rl.hex.tile.label.to_s == 'K' }
          super + K_BONUS[k_sum]
        end

        # recievership

        def close_corporation(corporation, quiet: false)
          @close_corp_count += 1
          @player_corp_close_count[corporation.owner] += 1

          # boe gets all the tokens
          corporation.tokens.each do |token|
            next if token.used

            boe_token = Engine::Token.new(@boe)
            token.swap!(boe_token)
            @boe.tokens << boe_token
          end

          # shareholders compensated
          per_share = corporation.par_price.price
          payouts = {}
          @players.each do |player|
            next if corporation.president?(player)

            amount = player.num_shares_of(corporation) * per_share
            next if amount.zero?

            payouts[player] = amount
            corporation.spend(amount, player, check_cash: false, borrow_from: corporation.owner)
          end

          unless payouts.empty?
            receivers = payouts
                          .sort_by { |_r, c| -c }
                          .map { |receiver, cash| "#{format_currency(cash)} to #{receiver.name}" }.join(', ')

            @log << "#{corporation.name} settles with shareholders "\
                    "#{format_currency(per_share)} per share (#{receivers})"
          end

          # cert limit adjustments
          players_size = @players.size
          @cert_limit = CERT_LIMIT_RECEIVERSHIP[players_size][@close_corp_count]

          # remove trains on 2nd and 5th company
          depot.export! if @close_corp_count == 2 || @close_corp_count == 5

          super
        end

        def custom_end_game_reached?
          @close_corp_count >= 5
        end

        def init_cert_limit
          return super unless @cert_limit.is_a?(Numeric)

          @cert_limit
        end

        def cert_limit(player)
          if @cert_limit.is_a?(Numeric) && player
            # player cert limit needs to be reduced
            @cert_limit - (@player_corp_close_count[player] * CERT_LIMIT_RECEIVERSHIP_REDUCTION[@players.size])
          else
            @cert_limit
          end
        end

        def init_train_handler
          trains = game_trains.flat_map do |train|
            Array.new((train[:num] || num_trains(train))) do |index|
              Train.new(**train, index: index)
            end
          end

          G1848::Depot.new(trains, self)
        end

        # recievership

        def close_corporation(corporation, quiet: false)
          @close_corp_count += 1
          # boe gets all the tokens
          corporation.tokens.select(&:used).each do |token|
            boe_token = Engine::Token.new(@boe)
            token.swap!(boe_token)
            @boe.tokens << boe_token
          end

          # shareholders compensated
          per_share = corporation.original_par_price.price
          # total_payout = corporation.total_shares * per_share
          payouts = {}
          @players.each do |player|
            next if corporation.president?(player)

            amount = player.num_shares_of(corporation) * per_share
            next if amount.zero?

            payouts[player] = amount
            corporation.spend(amount, player)
          end

          if payouts.any?
            receivers = payouts
                          .sort_by { |_r, c| -c }
                          .map { |receiver, cash| "#{format_currency(cash)} to #{receiver.name}" }.join(', ')

            @log << "#{corporation.name} settles with shareholders "\
                    "#{format_currency(per_share)} per share (#{receivers})"
          end

          # cert limit adjustments
          players_size = @players.size
          @cert_limit = CERT_LIMIT_RECEIVERSHIP[players_size][@close_corp_count]

          # remove trains on 2nd and 5th company

          # end game trigger if fifth company

          super
        end

        def init_cert_limit
          return super if @cert_limit.nil? && !@cert_limit.is_a?(Numeric)

          @cert_limit
        end

        def cert_limit(_player)
          @cert_limit
        end
      end
    end
  end
end
