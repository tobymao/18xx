# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'

require_relative '../base'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G1880
      class Game < Game::Base
        include_meta(G1880::Meta)
        include Map
        include Entities
        include StubsAreRestricted

        attr_accessor :train_marker
        attr_reader :full_cap_event, :communism, :end_game_triggered, :saved_or_round, :final_operating_rounds,
                    :foreign_investors_operate, :rocket_train

        TRACK_RESTRICTION = :permissive
        TILE_RESERVATION_BLOCKS_OTHERS = :single_slot_cities
        TILE_UPGRADES_MUST_USE_MAX_EXITS = %i[cities].freeze
        HOME_TOKEN_TIMING = :operating_round
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :down_per_10
        EBUY_PRES_SWAP = false
        EBUY_OTHER_VALUE = false
        CURRENCY_FORMAT_STR = '¥%s'
        SOLD_SHARES_DESTINATION = :corporation
        MINORS_CAN_OWN_SHARES = true
        CORPORATION_CLASS = G1880::Corporation
        DEPOT_CLASS = G1880::Depot
        ALLOW_TRAIN_BUY_FROM_OTHER_PLAYERS = false
        MUST_BUY_TRAIN = :always
        DISCARDED_TRAINS = :remove
        CERT_LIMIT_INCLUDES_PRIVATES = false
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false

        BANK_CASH = 37_860

        CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 14, 6 => 12, 7 => 11 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 480, 5 => 400, 6 => 340, 7 => 300 }.freeze

        GAME_END_CHECK = { custom: :one_more_full_or_set }.freeze
        P0_AWARD = { 'A2' => 40, 'B1' => 70, 'B2' => 100 }.freeze
        TRAINS_NOT_TRIGGERING_SR = %w[2P 8E 10].freeze

        GAME_END_REASONS_TEXT = {
          custom: 'Last 8 train sold',
        }.freeze

        GAME_END_REASONS_TIMING_TEXT = {
          one_more_full_or_set: '3 ORs ending with the Corporation that triggered game end',
        }.freeze

        GAME_END_DESCRIPTION_REASON_MAP_TEXT = {
          custom: 'Last 8 train was purchased',
        }.freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          pays_bonus: :yellow,
          pays_bonus_1: :orange,
          pays_bonus_2: :peach,
          pays_bonus_3: :olive,
          pays_bonus_4: :green,
        ).freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          pays_bonus: '+5 bonus per share',
          pays_bonus_1: '+10 bonus per share',
          pays_bonus_2: '+15 bonus per share',
          pays_bonus_3: '+20 bonus per share',
          pays_bonus_4: '+40 bonus per share',
        ).freeze

        MARKET = [
          ['', '', '100', '105', '110', '115B', '120B', '125B', '130W', '140W', '150X', '160X', '180Y', '200Z'],
          ['', '85', '95', '100p', '105', '110B', '115B', '120B', '125W', '135W', '145X', '155X', '170Y', '190Y'],
          %w[70 80 90 95 100 105B 110B 115B 120W 130W 140X 150X 165Y 180Y],
          %w[65 75 85 90p 95 100B 105B 110B 115W 125W 135X 145X],
          %w[60 70 80 85 90 95B 100B 105B 110W 120W],
          %w[55 65 75 80p 85 90B 95B 100B],
          %w[50 60 70 75 80 85B 90B],
          %w[45 55 65 70p 75 80B],
          %w[40 50 60 65 70],
        ].freeze

        PHASES = [{ name: 'A1', train_limit: 4, tiles: [:yellow] },
                  {
                    name: 'A2',
                    on: '2+2',
                    train_limit: 4,
                    tiles: %i[yellow],
                  },
                  {
                    name: 'B1',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                  },
                  {
                    name: 'B2',
                    on: '3+3',
                    train_limit: 3,
                    tiles: %i[yellow green],
                  },
                  {
                    name: 'B3',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green],
                  },
                  {
                    name: 'C1',
                    on: '4+4',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                  },
                  {
                    name: 'C2',
                    on: '6',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                  },
                  {
                    name: 'C3',
                    on: '6E',
                    train_limit: 2,
                    tiles: %i[yellow green brown],
                  },
                  {
                    name: 'D1',
                    on: '8',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                  },
                  {
                    name: 'D2',
                    on: '8E',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                  },
                  {
                    name: 'D3',
                    on: '10',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 10 },
                  {
                    name: '2+2',
                    distance: [{ 'nodes' => ['town'], 'pay' => 2, 'visit' => 2 },
                               { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
                    price: 180,
                    rusts_on: '4+4',
                    num: 5,
                  },
                  {
                    name: '3',
                    distance: 3,
                    price: 180,
                    rusts_on: '6',
                    num: 5,
                    events: [{ 'type' => 'float_30' },
                             { 'type' => 'permit_b' },
                             { 'type' => 'all_shares_available' },
                             { 'type' => 'receive_capital' },
                             { 'type' => 'can_buy_trains' }],
                  },
                  {
                    name: '3+3',
                    distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                               { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
                    price: 300,
                    rusts_on: '6E',
                    num: 5,
                  },
                  {
                    name: '4',
                    distance: 4,
                    price: 300,
                    rusts_on: '8',
                    num: 5,
                    events: [{ 'type' => 'float_40' },
                             { 'type' => 'communist_takeover' }],
                  },
                  {
                    name: '4+4',
                    distance: [{ 'nodes' => ['town'], 'pay' => 4, 'visit' => 4 },
                               { 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 }],
                    price: 450,
                    rusts_on: '8E',
                    num: 5,
                    events: [{ 'type' => 'float_40' }, { 'type' => 'permit_c' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 600,
                    num: 5,
                    events: [{ 'type' => 'float_60' },
                             { 'type' => 'stock_exchange_reopens' }],
                  },
                  {
                    name: '6E',
                    distance: [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 99 }],
                    price: 700,
                    num: 5,
                  },
                  {
                    name: '8',
                    distance: 8,
                    price: 800,
                    num: 2,
                    events: [{ 'type' => 'permit_d' }, { 'type' => 'token_cost_doubled' },
                             { 'type' => 'signal_end_game', 'when' => 2 }],
                  },
                  {
                    name: '8E',
                    distance: [{ 'nodes' => %w[city offboard town], 'pay' => 8, 'visit' => 99 }],
                    price: 900,
                    num: 2,
                  },
                  { name: '10', distance: 10, price: 1000, num: 10 },
                  { name: '2P', distance: 2, price: 250, num: 10, available_on: 'C2' }].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'float_30' => ['30% to Float', "Corporation's President must own 30% or corporation sold out to float"],
          'float_40' => ['40% to Float', "Corporation's President must own 40% or corporation sold out to float"],
          'float_60' => ['60% to Float', "Corporation's President must own 60% or corporation sold out to float"],
          'permit_b' => ['B Permit', 'Only corporations with a B building permit can build track'],
          'permit_c' => ['C Permit', 'Only corporations with a C building permit can build track'],
          'permit_d' => ['D Permit', 'Only corporations with a D building permit can build track'],
          'all_shares_available' => ['All 10 shares are available', 'Players can now buy all 10 shares'],
          'receive_capital' => ['Corporations receive capital',
                                'Corporations with 5 shares sold receive the rest of their capital'],
          'can_buy_trains' => ['Can buy trains', 'Corporations can buy trains from other corporations owned by the same player'],
          'token_cost_doubled' => ['Token Cost Doubled', 'Tokens cost twice as much to place'],
          'communist_takeover' => ['Communist Takeover',
                                   'No share price movement, no sales by director, no private payouts, ' \
                                   'foreign investors do not operate'],
          'stock_exchange_reopens' => ['Stock Exchange Reopens', 'Normal share price movement, director may sell shares'],
          'signal_end_game' => ['Signal End Game', 'Game ends 3 ORs after purchase of last 8 train']
        ).freeze

        def event_float_30!
          @log << "-- Event: #{EVENTS_TEXT['float_30'][1]} --"
          update_float_percent(30)
        end

        def event_float_40!
          @log << "-- Event: #{EVENTS_TEXT['float_40'][1]} --"
          update_float_percent(40)
        end

        def event_float_60!
          @log << "-- Event: #{EVENTS_TEXT['float_60'][1]} --"
          update_float_percent(60)
        end

        def update_float_percent(percent)
          @corporations.each do |c|
            next if c.type == :minor || c.floated?

            c.float_percent = percent
          end
        end

        def event_permit_b!
          @log << "-- Event: #{EVENTS_TEXT['permit_b'][1]} --"
          @active_building_permit = 'B'
        end

        def event_permit_c!
          @log << "-- Event: #{EVENTS_TEXT['permit_c'][1]} --"
          @active_building_permit = 'C'
        end

        def event_permit_d!
          @log << "-- Event: #{EVENTS_TEXT['permit_d'][1]} --"
          @active_building_permit = 'D'
        end

        def event_all_shares_available!
          @log << "-- Event: #{EVENTS_TEXT['all_shares_available'][1]} --"
          @corporations.each do |c|
            c.shares.each { |s| s.buyable = true }
          end
        end

        def event_receive_capital!
          @log << "-- Event: #{EVENTS_TEXT['receive_capital'][1]} --"
          @corporations.each do |c|
            receive_capital(c)
          end
          @full_cap_event = true
        end

        def receive_capital(corporation)
          return if corporation.ipo_shares.size > 5 || corporation.fully_funded

          amount = corporation.original_par_price.price * 5
          @log << "Five shares of #{corporation.name} have been bought. "\
                  "#{corporation.name} receives #{format_currency(amount)}"
          @bank.spend(amount, corporation)
          corporation.fully_funded = true
        end

        def event_communist_takeover!
          @log << "-- Event: #{EVENTS_TEXT['communist_takeover'][1]} --"
          @communism = true
          @foreign_investors_operate = false
          @companies.each { |c| c.revenue = 0 }
          force_exchange_rocket
        end

        def event_stock_exchange_reopens!
          @log << "-- Event: #{EVENTS_TEXT['stock_exchange_reopens'][1]} --"
          @communism = false
        end

        def event_token_cost_doubled!
          @log << "-- Event: #{EVENTS_TEXT['token_cost_doubled'][1]} --"
          @corporations.each do |c|
            c.tokens.reject(&:used).each { |t| t.price = t.price * 2 }
          end
        end

        def event_signal_end_game!
          @log << "-- Event: #{EVENTS_TEXT['signal_end_game'][1]} --"
          @end_game_triggered = true
          @final_operating_rounds = @round.round_num + 3
          game_end_check
        end

        def event_can_buy_trains!
          @log << "-- Event: #{EVENTS_TEXT['can_buy_trains'][1]} --"
          @can_cross_buy = true
        end

        def force_exchange_rocket
          return if rocket.closed?

          player_corps = @corporations.select { |c| c.owner == rocket.owner }

          if player_corps.empty?
            @log << "Rocket of China's owner, #{rocket.owner} owns no corporations. '\
                    'The rocket is exchanged for a 4 train, train is discarded."
            rocket.close!
            @depot.export!
          else
            # change rocket ability into assign
            fix_rocket_ability
          end
        end

        def fix_rocket_ability
          rocket.all_abilities.dup.each { |a| rocket.remove_ability(a) }

          assign_ability = Engine::Ability::AssignCorporation.new(
            type: :assign_corporation,
            closed_when_used_up: true,
            owner_type: 'player',
            count: 1,
          )
          rocket.add_ability(assign_ability)
        end

        def setup
          @full_cap_event = false
          @communism = false
          @foreign_investors_operate = true

          # Initialize the player depts, if player have to take an emergency loan
          @player_debts = Hash.new { |h, k| h[k] = 0 }

          setup_foreign_investors
          setup_building_permits
          setup_unsaleable_shares
        end

        def setup_foreign_investors
          @minors.each { |m| place_home_token(m) }
        end

        def setup_building_permits
          @active_building_permit = 'A'
          @building_permit_choices_by_president_percent = {
            20 => %w[ABC BCD],
            30 => %w[AB BC CD],
            40 => %w[A B C D],
          }
        end

        def setup_unsaleable_shares
          # reserve last 5 shares of each corp
          @corporations.each do |c|
            c.shares.last(5).each { |s| s.buyable = false }
          end
        end

        def new_auction_round
          Engine::Round::Auction.new(self, [
            G1880::Step::CompanyPendingPar,
            G1880::Step::SelectionAuction,
          ])
        end

        def new_draft_round
          Engine::Round::Draft.new(self, [G1880::Step::SimpleDraft], reverse_order: false)
        end

        def next_round!
          @round =
            case @round
            when Engine::Round::Stock
              reorder_players
              if @saved_or_round
                @log << '--Return to Operating Round--'
                @saved_or_round
              else
                new_operating_round
              end
            when Engine::Round::Operating
              if @sr_triggered
                @sr_triggered = false
                @saved_or_round = @round
                @turn += 1
                new_stock_round
              else
                or_round_finished
                new_operating_round(@round.round_num + 1)
              end
            when Engine::Round::Draft
              new_stock_round
            when init_round.class
              init_round_finished
              reorder_players(:least_cash, log_player_order: true)
              new_draft_round
            end
        end

        def stock_round
          G1880::Round::Stock.new(self, [
            G1880::Step::Choose,
            Engine::Step::Exchange,
            G1880::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G1880::Round::Operating.new(self, [
            Engine::Step::HomeToken,
            G1880::Step::RocketPurchaseTrain,
            Engine::Step::Exchange,
            Engine::Step::DiscardTrain,
            G1880::Step::Assign,
            G1880::Step::Track,
            G1880::Step::Token,
            G1880::Step::Route,
            G1880::Step::Dividend,
            G1880::Step::BuyTrain,
            G1880::Step::CheckFIConnection,
          ], round_num: round_num)
        end

        def init_stock_market
          market = G1880::StockMarket.new(self.class::MARKET, [],
                                          multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
          market.game = self
          market
        end

        def init_share_pool
          G1880::SharePool.new(self)
        end

        def init_minors
          game_minors.map { |minor| G1880::Minor.new(**minor) }
        end

        def custom_end_game_reached?
          @end_game_triggered
        end

        def end_game!(player_initiated: false)
          return if @finished

          @minors.each do |m|
            next unless m&.owner

            cash_to_owner = (m.cash * 0.2).floor
            if cash_to_owner.positive?
              @log << "#{m.name} transfers #{format_currency(cash_to_owner)} to #{m.owner.name}"
              m.spend(cash_to_owner, m.owner)
            end
            close_corporation(m)
          end

          super
        end

        def p1
          @p1 ||= company_by_id('P1')
        end

        def p0
          @p0 ||= company_by_id('P0')
        end

        def p5
          @p5 ||= company_by_id('P5')
        end

        def rocket
          @rocket ||= company_by_id('P7')
        end

        def bcr
          @bcr ||= corporation_by_id('BCR')
        end

        def status_array(corporation)
          return if corporation.minor? || !corporation.ipoed

          status = ["Building Permits: #{corporation.building_permits}"]
          par_location = par_chart[corporation.original_par_price].find_index(corporation) + 1
          status << ["Par Price: #{format_currency(corporation.original_par_price.price)}-#{par_location}"]
          status
        end

        def corporation_show_individual_reserved_shares?(_corporation)
          false
        end

        def float_str(entity)
          return super if entity.percent_to_float.positive?

          'Ready to float'
        end

        def float_corporations
          @corporations.select { |c| !c.floated? && !c.percent_to_float.positive? }.each { |c| float_corporation(c) }
        end

        def float_corporation(corporation)
          corporation.float!
          @log << "#{corporation.name} floats"

          cash = corporation.original_par_price.price * 5
          @bank.spend(cash, corporation)
          @log << "#{corporation.name} receives #{format_currency(cash)}"
        end

        def assign_share_to_fi(corporation, foreign_investor)
          @share_pool.transfer_shares(corporation.ipo_shares.first.to_bundle, foreign_investor)
          @log << "#{foreign_investor.full_name} receives a share of #{corporation.name}"
        end

        def player_value(player)
          super - player_debt(player)
        end

        def player_debt(player)
          @player_debts[player] || 0
        end

        def take_player_loan(player, loan)
          # Give the player the money. The money for loans is outside money, doesnt count towards the normal bank money.
          player.cash += loan

          # Add interest to the loan, must atleast pay 150% of the loaned value
          interest = player_loan_interest(loan)
          @player_debts[player] += loan + interest
          @log << "#{player.name} takes a loan of #{format_currency(loan)} with "\
                  "#{format_currency(interest)} in interest"
        end

        def add_interest_player_loans!
          @player_debts.each do |player, loan|
            next unless loan.positive?

            interest = player_loan_interest(loan)
            new_loan = loan + interest
            @player_debts[player] = new_loan
            @log << "#{player.name} increases their loan by 50% (#{format_currency(interest)}) to "\
                    "#{format_currency(new_loan)}"
          end
        end

        def payoff_player_loan(player)
          # Pay full or partial of the player loan. The money from loans is outside money, doesnt count towards
          # the normal bank money.
          if player.cash >= @player_debts[player]
            player.cash -= @player_debts[player]
            @log << "#{player.name} pays off their loan of #{format_currency(@player_debts[player])}"
            @player_debts[player] = 0
          else
            @player_debts[player] -= player.cash
            @log << "#{player.name} decreases their loan by #{format_currency(player.cash)} "\
                    "(#{format_currency(@player_debts[player])})"
            player.cash = 0
          end
        end

        def player_loan_interest(loan)
          (loan * 0.5).ceil
        end

        def tile_lays(entity)
          return [] unless can_build_track?(entity)

          tile_lays = [{ lay: true, upgrade: true }]
          return tile_lays if entity.minor? || (entity != bcr && !@phase.tiles.include?(:green))

          tile_lays << { lay: :not_if_upgraded, upgrade: false }
          tile_lays
        end

        def upgrades_to_correct_label?(from, _to)
          return true if from.color == :white && from.cities.size == 2

          super
        end

        def upgrades_to_correct_city_town?(from, to)
          # Handle city/town option tile lays
          if !from.cities.empty? && !from.towns.empty?
            return to.cities.size == from.cities.size || to.towns.size == from.towns.size
          end

          super
        end

        def building_permit_choices(corporation)
          @building_permit_choices_by_president_percent[corporation.presidents_percent]
        end

        def can_build_track?(corporation)
          return @foreign_investors_operate if corporation.minor?

          corporation.building_permits&.include?(@active_building_permit)
        end

        def player_card_minors(player)
          @minors.select { |m| m.owner == player }
        end

        def routes_revenue(routes)
          revenue = super
          revenue += stock_market_bonus(@round.current_operator) unless revenue.zero?
          revenue
        end

        def revenue_for(route, stops)
          revenue = super
          revenue -= 10 * (route.all_hexes & ferry_hexes).size unless route.corporation.owner == ferry_company.owner

          stop_hexes = stops.map(&:hex)
          revenue += 20 if route.corporation.owner == taiwan_company.owner && stop_hexes.include?(taiwan_hex)
          revenue += 50 if trans_siberian_bonus?(stops)

          revenue
        end

        def revenue_str(route)
          str = super
          str += ' + Trans-Siberian' if trans_siberian_bonus?(route.stops)
          str
        end

        def ferry_hexes
          @ferry_hexes ||= %w[F12 F14 J16].map { |id| hex_by_id(id) }
        end

        def ferry_company
          @ferry_company ||= company_by_id('P2')
        end

        def taiwan_hex
          @taiwan_hex ||= hex_by_id('N16')
        end

        def taiwan_company
          @taiwan_company ||= company_by_id('P3')
        end

        def trans_siberian_bonus?(stops)
          @trans_siberian_hexes ||= %w[A3 A15].map { |id| hex_by_id(id) }
          stop_hexes = stops.map(&:hex)
          @trans_siberian_hexes.all? { |hex| stop_hexes.include?(hex) }
        end

        def stock_market_bonus(corporation)
          case corporation.share_price&.type
          when :pays_bonus
            50
          when :pays_bonus_1
            100
          when :pays_bonus_2
            150
          when :pays_bonus_3
            200
          when :pays_bonus_4
            400
          else
            0
          end
        end

        def route_trains(entity)
          entity.minor? ? [@depot.min_depot_train] : super
        end

        def train_owner(train)
          train.owner == @depot ? lessee : train.owner
        end

        def lessee
          current_entity
        end

        def round_description(name, round_number = nil)
          round_number ||= @round.round_num
          description = super
          description += ".#{round_number}" if name == self.class::OPERATING_ROUND_NAME
          description += " - Train Marker at #{@train_marker.name}" if @train_marker && !@end_game_triggered
          description
        end

        def check_for_foreign_investor_connection(fi)
          return false unless fi&.shares&.first

          corporation = fi.shares.first.corporation
          fi_home_token = fi.tokens.first.hex

          graph = Graph.new(self, no_blocking: true)
          graph.reachable_hexes(corporation).include?(fi_home_token)
        end

        def operating_order
          @minors.select(&:floated?) + par_chart.values.flatten.compact.select(&:floated?)
        end

        def after_buying_train(train, source)
          return unless trigger_sr?(train, source)

          if train.name == '4' && !rocket.closed? && @depot.upcoming.first.name != train.name
            @rocket_train = train
            return
          end

          @sr_triggered = true
          transition_to_next_round!
        end

        def trigger_sr?(train, source)
          train.name != @depot.upcoming.first.name &&
          !trains_not_triggering_sr?(train.name) &&
          source == @depot
        end

        def set_par(corporation, share_price, slot)
          par_chart[share_price][slot] = corporation
        end

        def par_chart
          @par_chart ||=
            share_prices.sort_by { |sp| -sp.price }.to_h { |sp| [sp, [nil, nil, nil, nil]] }
        end

        def current_operator
          op_round = @round.is_a?(Engine::Round::Operating) ? @round : @saved_or_round
          op_round&.current_operator
        end

        def must_buy_train?(entity)
          entity.trains.reject { |t| t.name == '2P' }.empty?
        end

        def additional_ending_after_text
          " #{@train_marker.name}'s turn"
        end

        def trains_not_triggering_sr?(train_name)
          TRAINS_NOT_TRIGGERING_SR.include?(train_name)
        end

        def forced_exchange_rocket?
          phase.name == 'B3' && !rocket.closed?
        end

        def can_cross_buy?
          @can_cross_buy
        end
      end
    end
  end
end
