# frozen_string_literal: true

require_relative 'corporation'
require_relative 'depot'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G1837
      class Game < Game::Base
        include_meta(G1837::Meta)
        include Entities
        include Map

        CORPORATION_CLASS = G1837::Corporation
        DEPOT_CLASS = G1837::Depot

        CURRENCY_FORMAT_STR = '%sK'

        BANK_CASH = 14_268
        STARTING_CASH = { 3 => 730, 4 => 555, 5 => 450, 6 => 380, 7 => 330 }.freeze

        CERT_LIMIT = { 3 => 28, 4 => 21, 5 => 17, 6 => 14, 7 => 12 }.freeze

        SELL_BUY_ORDER = :sell_buy
        SELL_AFTER = :operate
        SELL_MOVEMENT = :down_block
        MUST_SELL_IN_BLOCKS = true

        HOME_TOKEN_TIMING = :float

        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        EBUY_FROM_OTHERS = :always
        EBUY_SELL_MORE_THAN_NEEDED = true
        EBUY_SELL_MORE_THAN_NEEDED_SETS_PURCHASE_MIN = true
        MUST_BUY_TRAIN = :always

        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one
        GAME_END_CHECK = { bankrupt: :immediate, bank: :current_or }.freeze

        MARKET = [
          %w[95 99 104p 114 121 132 145 162 181 205 240 280 350 400 460],
          %w[89 93 97p 102 111 118 128 140 154 173 195 225 260 300 360],
          %w[84 87 91p 95 100 108 115 124 135 148 165 185 210 240 280],
          %w[79 82 85p 89 93 98 105 112 120 130 142 157 175],
          %w[74 77 80p 83 87 91 96 102 109 116 125],
          %w[69y 72 75p 78 81 85 89 94 99 106],
          %w[64y 67y 70p 73 76 79 83 87],
          %w[59y 62y 65y 68 71 74 77],
          %w[54y 57y 60y 63y 66 69 72],
        ].freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Major Corporation Par')

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(par_1: :brown, par_2: :orange, par_3: :pink).freeze

        PHASES = [
          {
            name: '2',
            train_limit: { coal: 2, minor: 2, major: 4, national: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: { coal: 2, minor: 2, major: 3, national: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '3+1',
            on: '3+1',
            train_limit: { coal: 1, minor: 1, major: 3, national: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { coal: 1, minor: 1, major: 3, national: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { major: 2, national: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            num: 14,
            distance: 2,
            price: 90,
            rusts_on: '4',
          },
          {
            name: '3',
            num: 5,
            distance: 3,
            price: 180,
            rusts_on: '5',
            events: [{ 'type' => 'buy_across' }],
          },
          {
            name: '3+1',
            num: 2,
            distance: [
              { 'nodes' => %w[town], 'pay' => 1, 'visit' => 1 },
              { 'nodes' => %w[town city offboard], 'pay' => 3, 'visit' => 3 },
            ],
            price: 280,
            rusts_on: '5+2',
          },
          {
            name: '4',
            num: 4,
            distance: 4,
            price: 470,
            events: [{ 'type' => 'sd_formation' }, { 'type' => 'kk_can_form' }, { 'type' => 'remove_italy' }],
          },
          {
            name: '4E',
            num: 1,
            distance: [
              { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 },
              { 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
            ],
            price: 500,
            events: [{ 'type' => 'ug_can_form' }],
          },
          {
            name: '4+1',
            num: 1,
            distance: [
              { 'nodes' => %w[town], 'pay' => 1, 'visit' => 1 },
              { 'nodes' => %w[town city offboard], 'pay' => 4, 'visit' => 4 },
            ],
            price: 530,
            events: [{ 'type' => 'kk_formation' }],
          },
          {
            name: '4+2',
            num: 1,
            distance: [
              { 'nodes' => %w[town], 'pay' => 2, 'visit' => 2 },
              { 'nodes' => %w[town city offboard], 'pay' => 4, 'visit' => 4 },
            ],
            price: 560,
          },
          {
            name: '5',
            num: 2,
            distance: 5,
            price: 800,
            events: [{ 'type' => 'ug_formation' }, { 'type' => 'exchange_coal_companies' },
                     { 'type' => 'close_mountain_railways' }],
          },
          {
            name: '5E',
            num: 1,
            distance: [
              { 'nodes' => %w[town], 'pay' => 0, 'visit' => 99 },
              { 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
            ],
            price: 830,
          },
          {
            name: '5+2',
            num: 1,
            distance: [
              { 'nodes' => %w[town], 'pay' => 2, 'visit' => 2 },
              { 'nodes' => %w[town city offboard], 'pay' => 5, 'visit' => 5 },
            ],
            price: 860,
          },
          {
            name: '5+3',
            num: 1,
            distance: [
              { 'nodes' => %w[town], 'pay' => 3, 'visit' => 3 },
              { 'nodes' => %w[town city offboard], 'pay' => 5, 'visit' => 5 },
            ],
            price: 900,
          },
          {
            name: '5+4',
            num: 20,
            distance: [
              { 'nodes' => %w[town], 'pay' => 4, 'visit' => 4 },
              { 'nodes' => %w[town city offboard], 'pay' => 5, 'visit' => 5 },
            ],
            price: 960,
          },
          {
            name: '1G',
            num: 10,
            distance: [
              { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
              { 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
            ],
            available_on: '2',
            rusts_on: %w[3G 4G],
            price: 100,
          },
          {
            name: '2G',
            num: 6,
            distance: [
              { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
              { 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
            ],
            available_on: '3',
            rusts_on: '4G',
            price: 230,
          },
          {
            name: '3G',
            num: 2,
            distance: [
              { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
              { 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
            ],
            available_on: '4',
            price: 590,
          },
          {
            name: '4G',
            num: 20,
            distance: [
              { 'nodes' => %w[town], 'pay' => 99, 'visit' => 99 },
              { 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
            ],
            available_on: '5',
            price: 1000,
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'buy_across' => ['Buy Across', 'Trains can be bought between companies'],
          'sd_formation' => ['SD Formation', 'SD forms immediately'],
          'remove_italy' => ['Remove Italy', 'Remove tiles in Italy. Italy no longer in play.'],
          'kk_can_form' => ['Optional KK Formation', 'KK can choose to form at beginning of SR/OR'],
          'kk_formation' => ['KK Formation', 'KK forms immediately'],
          'ug_can_form' => ['Optional UG Formation', 'UG can choose to form at beginning of SR/OR'],
          'ug_formation' => ['UG Formation', 'UG forms immediately'],
          'exchange_coal_companies' => ['Exchange Coal Companies', 'All remaining coal companies are exchanged'],
          'close_mountain_railways' => ['Mountain Railways Close', 'All Mountain Railways close'],
        ).freeze

        ASSIGNMENT_TOKENS = {
          'coal' => '/icons/1837/coalcar.svg',
        }.freeze

        def company_header(company)
          return 'COAL COMPANY' if company.color == :black
          return 'MOUNTAIN RAILWAY' if company.color == :gray
          return 'MINOR SHARE' if company.sym.end_with?('_share')

          'MINOR COMPANY'
        end

        def par_chart
          @par_chart ||=
            share_prices.select { |sp| sp.type == :par }.sort_by { |sp| -sp.price }.to_h { |sp| [sp, [nil, nil]] }
        end

        def set_par(corporation, share_price, slot)
          par_chart[share_price][slot] = corporation
        end

        def init_stock_market
          StockMarket.new(game_market, self.class::CERT_LIMIT_TYPES, hex_market: true)
        end

        def initial_auction_companies
          @companies.select { |company| company.meta[:start_packet] }
        end

        def setup
          non_purchasable = @companies.flat_map do |c|
            [abilities(c, :acquire_company, time: 'any')&.company, c.meta[:hidden] ? c.id : nil]
          end.compact
          @companies.each { |company| company.owner = @bank unless non_purchasable.include?(company.id) }
          setup_mines
          setup_minors
          setup_nationals
        end

        def setup_mines
          self.class::MINE_HEXES.each do |hex_id|
            hex_by_id(hex_id).assign!(:coal)
          end
        end

        def setup_minors
          @minors.each { |minor| reserve_minor_home(minor) }
        end

        def reserve_minor_home(minor)
          Array(minor.coordinates).zip(Array(minor.city)).each do |coords, city|
            hex_by_id(coords).tile.cities[city || 0].add_reservation!(minor)
          end
        end

        def minor_initial_cash(minor)
          case minor.id
          when 'SD1', 'SD2', 'SD3', 'SD4', 'SD5', 'KK1', 'KK3', 'UG2'
            90
          when 'KK2'
            140
          when 'UG1', 'UG3'
            180
          else
            100
          end
        end

        def setup_nationals
          market_row = @stock_market.market[3]
          { 'KK' => 120, 'SD' => 142, 'UG' => 175 }.each do |id, par_value|
            corporation = corporation_by_id(id)
            share_price = market_row.find { |sp| sp.price == par_value }
            @stock_market.set_par(corporation, share_price)
            corporation.ipoed = true
          end
        end

        def sd_minors
          @sd_minors ||= %w[SD1 SD2 SD3 SD4 SD5].map { |id| corporation_by_id(id) }
        end

        def kk_minors
          @kk_minors ||= %w[KK1 KK2 KK3].map { |id| corporation_by_id(id) }
        end

        def ug_minors
          @ug_minors ||= %w[UG1 UG2 UG3].map { |id| corporation_by_id(id) }
        end

        def coal_minors
          @coal_minors ||= %w[EPP RGTE EOD EKT MLB ZKB SPB LRB BB EHS].map { |id| corporation_by_id(id) }
        end

        def coal_minor?(entity)
          coal_minors.include?(entity)
        end

        def event_buy_across!
          @log << "-- Event: #{EVENTS_TEXT['buy_across'][1]} --"
        end

        def event_sd_formation!
          @log << "-- Event: #{EVENTS_TEXT['sd_formation'][1]} --"
          national = corporation_by_id('SD')
          form_national_railway!(national, sd_minors)
        end

        def event_remove_italy!
          @log << "-- Event: #{EVENTS_TEXT['remove_italy'][1]} --"
          ITALY_HEXES.each do |id|
            hex = hex_by_id(id)
            hex.lay_downgrade(hex.original_tile) if hex.tile != hex.original_tile
            hex.tile.modify_borders(type: :impassable)
          end

          # Lay Bo tile on Bozen
          hex_by_id('K5').lay(tile_by_id('426-0').rotate!(2))
          @graph.clear_graph_for_all
        end

        def event_kk_can_form!
          @log << "-- Event: #{EVENTS_TEXT['kk_can_form'][1]} --"
          @kk_can_form = true
        end

        def event_kk_formation!
          open_minors = kk_minors.reject(&:closed?)
          return if open_minors.empty?

          @log << "-- Event: #{EVENTS_TEXT['kk_formation'][1]} --"
          national = corporation_by_id('KK')
          if open_minors.find { |m| m.name == 'KK1' }
            form_national_railway!(national, open_minors)
          else
            @log << "#{national.name} already formed. Remaining minors must fold in."
            open_minors.each { |m| merge_minor!(m, national) }
          end
        end

        def event_ug_can_form!
          @log << "-- Event: #{EVENTS_TEXT['ug_can_form'][1]} --"
          @ug_can_form = true
        end

        def event_ug_formation!
          open_minors = ug_minors.reject(&:closed?)
          return if open_minors.empty?

          national = corporation_by_id('UG')
          @log << "-- Event: #{EVENTS_TEXT['ug_formation'][1]} --"
          if open_minors.find { |m| m.name == 'UG1' }
            form_national_railway!(national, open_minors)
          else
            @log << "#{national.name} already formed. Remaining minors must fold in."
            open_minors.each { |m| merge_minor!(m, national) }
          end
        end

        def event_exchange_coal_companies!
          @log << "-- Event: #{EVENTS_TEXT['exchange_coal_companies'][1]} --"
          coal_minor_exchange_order(mandatory: true).each { |c| exchange_coal_minor(c) }
        end

        def operating_order
          minors, majors = @corporations.select(&:floated?).partition { |c| c.type == :minor }
          @minors.select(&:floated?) + minors + majors.sort
        end

        def exchange_order
          order = coal_minor_exchange_order
          order.concat(kk_minors.reject(&:closed?)) if @kk_can_form
          order.concat(ug_minors.reject(&:closed?)) if @ug_can_form
          order
        end

        def exchange_target(entity)
          if coal_minor?(entity)
            target_id = abilities(entity, :exchange, time: 'any')&.corporations&.first
            corporation_by_id(target_id)
          elsif sd_minors.include?(entity)
            corporation_by_id('SD')
          elsif kk_minors.include?(entity)
            corporation_by_id('KK')
          elsif ug_minors.include?(entity)
            corporation_by_id('UG')
          end
        end

        def coal_minor_exchange_order(mandatory: false)
          exchangeable_coal_minors = Hash.new { |h, k| h[k] = [] }
          coal_minors.each do |c|
            next if c.closed? || !c.owner&.player?
            next unless (target = exchange_target(c))

            exchangeable_coal_minors[target] << c
          end

          order = operating_order
          order = order.concat(@corporations).uniq if mandatory
          order.select { |c| c.corporation? && c.type == :major }.flat_map do |major|
            player_order = major.owner&.player? ? @players.rotate(@players.index(major.owner)) : @players
            exchangeable_coal_minors[major].sort_by { |c| player_order.index(c.owner) }
          end.compact
        end

        def mandatory_coal_minor_exchange?(minor)
          return false if minor.closed? || !minor.owner&.player?

          exchange_target(minor).percent_ipo_buyable.zero?
        end

        def exchange_coal_minor(minor)
          target = exchange_target(minor)
          @log << "#{minor.id} exchanged for a share of #{target.id}"
          merge_minor!(minor, target)
        end

        def event_close_mountain_railways!
          @log << "-- Event: #{EVENTS_TEXT['close_mountain_railways'][1]} --"
          @companies.select { |c| c.meta[:type] == :mountain_railway }.each(&:close!)
        end

        def form_national_railway!(national, merging_minors)
          @log << "#{national.id} forms"
          national.floatable = true
          national.floated = true
          ipo_cash = (10 - national.num_ipo_reserved_shares) * national.par_price.price
          @bank.spend(ipo_cash, national)
          @log << "#{national.name} receives #{format_currency(ipo_cash)}"

          tie_breaker_order = []
          merging_minors.sort_by(&:name).each do |minor|
            tie_breaker_order << minor.owner
            merge_minor!(minor, national, allow_president_change: false)
          end
          set_national_president!(national, tie_breaker_order.uniq)
        end

        def merge_minor!(minor, corporation, allow_president_change: true)
          @log << "#{minor.name} merges into #{corporation.name}"

          minor.share_holders.each do |sh, _|
            num_shares = sh.shares_of(minor).size
            next if num_shares.zero?

            @log << "#{sh.name} receives #{num_shares} share#{num_shares > 1 ? 's' : ''} of #{corporation.name}"
            shares = corporation.reserved_shares.take(num_shares)
            shares.each { |s| s.buyable = true }
            @share_pool.transfer_shares(ShareBundle.new(shares), sh, allow_president_change: allow_president_change)
            if @round.respond_to?(:non_paying_shares) && operated_this_round?(minor)
              @round.non_paying_shares[sh][corporation] += num_shares
            end
          end

          if minor.cash.positive?
            @log << "#{corporation.name} receives #{format_currency(minor.cash)}"
            minor.spend(minor.cash, corporation)
          end

          unless minor.trains.empty?
            @log << "#{corporation.name} receives #{minor.trains.map(&:name).join(', ')} train#{minor.trains.size > 1 ? 's' : ''}"
            @round.merged_trains[corporation].concat(minor.trains)
            minor.trains.dup.each { |t| buy_train(corporation, t, :free) }
          end

          if coal_minor?(minor)
            minor.tokens.first.swap!(blocking_token, check_tokenable: false)
          else
            token = minor.tokens.first
            new_token = Token.new(corporation)
            corporation.tokens << new_token
            if %w[L2 L8].include?(token.hex.id)
              new_token.price = 20
            else
              token.swap!(new_token, check_tokenable: false)
            end
            @log << "#{corporation.name} receives token (#{new_token.used ? new_token.city.hex.id : 'charter'})"
          end

          close_corporation(minor, quiet: true)
          graph.clear_graph_for(corporation)
        end

        def close_minor!(minor)
          minor.tokens.each(&:remove!)
          minor.close!
        end

        def set_national_president!(national, tie_breaker = [])
          tie_breaker = tie_breaker.reverse
          current_president = national.owner || national

          # president determined by most shares, then tie breaker, then current president
          president_factors = national.player_share_holders.to_h do |player, percent|
            [[percent, tie_breaker.index(player) || -1, player == current_president ? 1 : 0], player]
          end
          president = president_factors[president_factors.keys.max]
          return unless current_president != president

          @log << "#{president.name} becomes the president of #{national.name}"
          @share_pool.change_president(national.presidents_share, current_president, president)
          national.owner = president
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_exchange_round(Round::Operating)
            when Round::Exchange
              if @round_after_exchange == Engine::Round::Stock
                new_stock_round
              else
                new_operating_round(@round.round_num)
              end
            when Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_exchange_round(Round::Operating, @round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_exchange_round(Engine::Round::Stock)
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1837::Step::SelectionAuction,
          ])
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G1837::Step::HomeToken,
            G1837::Step::DiscardTrain,
            G1837::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G1837::Round::Operating.new(self, [
            G1837::Step::Bankrupt,
            G1837::Step::HomeToken,
            G1837::Step::DiscardTrain,
            G1837::Step::SpecialTrack,
            G1837::Step::Track,
            G1837::Step::Token,
            Engine::Step::Route,
            G1837::Step::Dividend,
            G1837::Step::BuyTrain,
          ], round_num: round_num)
        end

        def new_exchange_round(next_round, round_num = 1)
          @round_after_exchange = next_round
          exchange_round(round_num)
        end

        def exchange_round(round_num)
          G1837::Round::Exchange.new(self, [
            G1837::Step::DiscardTrain,
            G1837::Step::CoalExchange,
            G1837::Step::MinorExchange,
          ], round_num: round_num)
        end

        def corporation_show_individual_reserved_shares?
          false
        end

        def unowned_purchasable_companies(_entity)
          @companies.select { |company| company.meta[:start_packet] }
          @companies.select { |c| c.owner == @bank }
        end

        def after_buy_company(player, company, _price)
          abilities(company, :shares) do |ability|
            share = ability.shares.first
            @share_pool.buy_shares(player, share, exchange: :free)
            float_minor!(share.corporation) if share.president
          end

          abilities(company, :acquire_company) do |ability|
            acquired_company = company_by_id(ability.company)
            acquired_company.owner = player
            player.companies << acquired_company
            @log << "#{player.name} receives #{acquired_company.name}"
            after_buy_company(player, acquired_company, 0)
          end

          company.close! unless company.meta[:type] == :mountain_railway
        end

        def float_str(entity)
          return 'Not floatable' if entity.corporation? && !entity.floatable

          super
        end

        def float_minor!(minor)
          cash = minor_initial_cash(minor)
          @bank.spend(cash, minor)
          @log << "#{minor.name} receives #{format_currency(cash)}"
          if !@round.is_a?(Engine::Round::Auction) && minor.id == 'SD5'
            coordinates = minor.coordinates.dup
            minor.coordinates = coordinates[0]
            remove_reservation!(minor, coordinates[1])
          end
          place_home_token(minor) unless minor.coordinates.is_a?(Array)
          if minor.corporation?
            minor.floated = true
          else
            minor.float!
          end
        end

        def float_corporation(corporation)
          @log << "#{corporation.name} floats"
          @bank.spend(corporation.par_price.price * corporation.total_ipo_shares, corporation)
          @log << "#{corporation.name} receives #{format_currency(corporation.cash)}"
        end

        def home_token_locations(corporation)
          Array(corporation.coordinates).map { |coord| hex_by_id(coord) }
        end

        def remove_reservation!(entity, coordinates)
          hex_by_id(coordinates).tile.remove_reservation!(entity)
        end

        def train_limit(entity)
          return 2 if ug_minors.include?(entity)

          super
        end

        def must_buy_train?(entity)
          %i[major national].include?(entity.type) && super
        end

        def goods_train?(train_name)
          train_name.end_with?('G')
        end

        def express_train?(train_name)
          train_name.end_with?('E')
        end

        def can_buy_train_from_others?
          @phase.name.to_i >= 3
        end

        def revenue_for(route, stops)
          super - mine_revenue(route, stops)
        end

        def check_other(route)
          if express_train?(route.train.name) && (route.stops.count { |s| s.type == :city } < 2)
            raise GameError, 'Must include at least two cities'
          end

          mine_stops = route.stops.count { |s| s.hex.assigned?(:coal) }
          if goods_train?(route.train.name)
            raise GameError, 'Must visit one mine' if mine_stops.zero?
            raise GameError, 'Cannot visit more than one mine' if mine_stops > 1
          elsif mine_stops.positive?
            raise GameError, 'Only goods trains can visit a mine'
          end
        end

        def route_distance(route)
          return route.stops.count { |s| s.type == :city } if express_train?(route.train.name)

          super
        end

        def routes_subsidy(routes)
          routes.sum { |route| mine_revenue(route, route.stops) }
        end

        def mine_revenue(route, stops)
          stops.select { |s| s.hex.assigned?(:coal) }.sum { |s| s.route_revenue(route.phase, route.train) }
        end

        def subsidy_name
          'mine revenue'
        end

        def blocking_token
          @blocker ||= Corporation.new(sym: 'B', name: '', logo: '1837/blocking', tokens: [])
          Token.new(@blocker)
        end

        def token_graph_for_entity(_entity)
          @token_graph ||= Graph.new(self, backtracking: true)
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          return yellow_town_tile_upgrades_to?(from, to) if from.color == :yellow && !from.towns.empty?

          super
        end

        def yellow_town_tile_upgrades_to?(from, to)
          # honors pre-existing track?
          return false unless from.paths_are_subset_of?(to.paths)

          if from.towns.one?
            self.class::YELLOW_SINGLE_TOWN_UPGRADES.include?(to.name)
          else
            self.class::YELLOW_DOUBLE_TOWN_UPGRADES.include?(to.name)
          end
        end

        def legal_tile_rotation?(entity, hex, tile)
          return tile.rotation == 5 if tile.name == '436'
          return false if !hex.tile.towns.empty? && !(hex.tile.exits - tile.towns.first.exits).empty?

          super
        end

        def sold_out?(corporation)
          corporation.percent_ipo_buyable.zero? && corporation.num_market_shares.zero?
        end

        def sold_out_stock_movement(corporation)
          if corporation.owner.percent_of(corporation) <= 40
            @stock_market.move_up(corporation)
          else
            @stock_market.move_diagonally_up_left(corporation)
          end
        end

        def operated_this_round?(entity)
          entity.operating_history.include?([@turn, @round.round_num])
        end

        def acting_for_entity(entity)
          if entity.corporation? && entity.type != :minor && entity.receivership?
            return @players.find { |p| p.num_shares_of(entity).positive? } || @players.first
          end

          super
        end

        def sellable_bundles(player, corporation)
          return [] unless corporation.share_price

          super
        end
      end
    end
  end
end
