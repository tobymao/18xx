# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18NewEngland
      class Game < Game::Base
        include_meta(G18NewEngland::Meta)
        include Entities
        include Map

        register_colors(black: '#16190e',
                        blue: '#0189d1',
                        brown: '#7b352a',
                        gray: '#7c7b8c',
                        green: '#3c7b5c',
                        olive: '#808000',
                        lightGreen: '#009a54ff',
                        lightBlue: '#4cb5d2',
                        lightishBlue: '#0097df',
                        teal: '#009595',
                        orange: '#d75500',
                        magenta: '#d30869',
                        purple: '#772282',
                        red: '#ef4223',
                        rose: '#b7274c',
                        coral: '#f3716d',
                        white: '#fff36b',
                        navy: '#000080',
                        cream: '#fffdd0',
                        yellow: '#ffdea8')

        CURRENCY_FORMAT_STR = '$%s'
        BANK_CASH = 12_000
        CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 13 }.freeze
        STARTING_CASH = { 3 => 400, 4 => 280, 5 => 280 }.freeze
        CAPITALIZATION = :full
        MUST_SELL_IN_BLOCKS = false

        TOP_MINOR_ROW = 0
        BOTTOM_MINOR_ROW = 1
        MAJOR_ROW = 2
        MARKET = [
          [
            '', '', '',
            '50r',
            '55r',
            '60r',
            '65r',
            '70r',
            '80r',
            '90r',
            '100r'
          ],
          [
            '', '', '',
            '50r',
            '55r',
            '60r',
            '65r',
            '70r',
            '80r',
            '90r',
            '100r'
          ],
          %w[35
             40
             45
             50
             55
             60
             65
             70
             80
             90
             100p
             110p
             120p
             130p
             145p
             160p
             180p
             200p
             220
             240
             260
             280
             310
             340
             380
             420
             460
             500e],
           ].freeze

        MARKET_TEXT = {
          par: 'Par value',
          no_cert_limit: 'Corporation shares do not count towards cert limit',
          unlimited: 'Corporation shares can be held above 60%',
          multiple_buy: 'Can buy more than one share in the corporation per turn',
          close: 'Corporation closes',
          endgame: 'End game trigger',
          liquidation: 'Liquidation',
          repar: 'Minor company value',
          ignore_one_sale: 'Ignore first share sold when moving price',
        }.freeze

        PHASES = [
          {
            name: '2',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5E',
            train_limit: { minor: 1, major: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6E',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '8',
            on: '8E',
            train_limit: { minor: 1, major: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 10,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6E',
            num: 7,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '8E',
            num: 4,
          },
          {
            name: '5E',
            distance: 5,
            price: 500,
            num: 4,
          },
          {
            name: '6E',
            distance: 6,
            price: 600,
            num: 3,
          },
          {
            name: '8E',
            distance: 8,
            price: 800,
            num: 20,
          },
        ].freeze

        HOME_TOKEN_TIMING = :operating_round
        MUST_BUY_TRAIN = :always
        SELL_MOVEMENT = :left_share_pres
        SELL_BUY_ORDER = :sell_buy
        GAME_END_CHECK = { stock_market: :current_or, bankrupt: :immediate, bank: :full_or }.freeze
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one
        LIMIT_TOKENS_AFTER_MERGER = 999
        SOLD_OUT_INCREASE = false
        EBUY_OTHER_VALUE = false

        YELLOW_PRICES = [50, 55, 60, 65, 70].freeze
        GREEN_PRICES = [80, 90, 100].freeze
        NUM_START_MINORS = 10
        START_RESERVATION_COLOR = 'cyan'
        RESERVED_RESERVATION_COLOR = 'lightgray'
        FORMED_RESERVATION_COLOR = 'gray'

        # Two lays or one upgrade
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: :not_if_upgraded, upgrade: false },
        ].freeze

        # one lay or one upgrade
        MINOR_TILE_LAYS = [
          { lay: true, upgrade: true },
        ].freeze

        def setup
          # adjust parameters for majors to allow both IPO and treasury stock
          #
          @corporations.each do |corp|
            next if corp.type == :minor

            corp.ipo_owner = @bank
            corp.always_market_price = true
            corp.share_holders.keys.each do |sh|
              next if sh == @bank

              sh.shares_by_corporation[corp].dup.each { |share| transfer_share(share, @bank) }
            end
          end

          # pick initial minors
          #
          num_start = self.class::NUM_START_MINORS
          num_start = num_start[players.size] if num_start.is_a?(Hash)
          @starting_minors = @corporations.select { |c| c.type == :minor }.sort_by { rand }.take(num_start)

          # highlight the starting minors
          @starting_minors.each { |m| m.reservation_color = self.class::START_RESERVATION_COLOR }

          # add yellow and green minor placeholders to stock market
          #
          @yellow_dummy = @minors.find { |d| d.name == 'Y' }
          @green_dummy = @minors.find { |d| d.name == 'G' }
          @closed_dummy = @minors.find { |d| d.name == 'C' }

          minor_yellow_prices.each do |p|
            p.corporations << @yellow_dummy
          end

          minor_green_prices.each do |p|
            p.corporations << @green_dummy
          end

          @minor_prices = Hash.new { |h, k| h[k] = 0 }
          @reserved = {}

          @log << '-- First Stock Round --'
        end

        def transfer_share(share, new_owner)
          corp = share.corporation
          corp.share_holders[share.owner] -= share.percent
          corp.share_holders[new_owner] += share.percent
          share.owner.shares_by_corporation[corp].delete(share)
          new_owner.shares_by_corporation[corp] << share
          share.owner = new_owner
        end

        def lookup_minor_price(p, row)
          @stock_market.market[row].size.times do |i|
            next unless @stock_market.share_price([row, i])
            return @stock_market.share_price([row, i]) if @stock_market.share_price([row, i]).price == p
          end
        end

        def lookup_par_price(p)
          @stock_market.market[MAJOR_ROW].size.times do |i|
            next unless @stock_market.share_price([MAJOR_ROW, i])
            return @stock_market.share_price([MAJOR_ROW, i]) if @stock_market.share_price([MAJOR_ROW, i]).price == p
            return @stock_market.share_price([MAJOR_ROW, i - 1]) if @stock_market.share_price([MAJOR_ROW, i]).price > p
          end
        end

        def total_rounds(name)
          # Return the total number of rounds for those with more than one.
          @operating_rounds if %w[Operating Merger].include?(name)
        end

        def init_round
          first_stock_round
        end

        def first_stock_round
          G18NewEngland::Round::FirstStock.new(self, [G18NewEngland::Step::ReserveParShares], snake_order: true)
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18NewEngland::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            G18NewEngland::Step::Bankrupt,
            G18NewEngland::Step::RedeemShares,
            G18NewEngland::Step::Track,
            Engine::Step::Token,
            G18NewEngland::Step::Route,
            G18NewEngland::Step::Dividend,
            Engine::Step::DiscardTrain,
            G18NewEngland::Step::BuyTrain,
            G18NewEngland::Step::IssueShares,
          ], round_num: round_num)
        end

        def init_round_finished
          @reserved = {}

          # un-highlight the starting minors
          @starting_minors.each { |m| m.reservation_color = nil }
        end

        def reorder_by_cash
          # this should break ties in favor of the closest to previous PD
          pd_player = @players.max_by(&:cash)
          @players.rotate!(@players.index(pd_player))
          @log << "Priority order: #{@players.map(&:name).join(', ')}"
        end

        def new_or!
          if @round.round_num < @operating_rounds
            new_operating_round(@round.round_num + 1)
          else
            @turn += 1
            or_set_finished
            new_stock_round
          end
        end

        def next_round!
          @round =
            case @round
            when init_round.class
              init_round_finished
              @operating_rounds = @phase.operating_rounds
              reorder_by_cash
              new_operating_round
            when Engine::Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Engine::Round::Operating
              or_round_finished
              if phase.name.to_i < 3
                new_or!
              else
                @log << "-- #{round_description('Merger', @round.round_num)} --"
                G18NewEngland::Round::Merger.new(self, [
                  G18NewEngland::Step::ReduceTokens,
                  G18NewEngland::Step::PostMergerShares,
                  G18NewEngland::Step::Merge,
                ], round_num: @round.round_num)
              end
            when G18NewEngland::Round::Merger
              new_or!
            end
        end

        def float_corporation(corporation)
          return unless corporation.type == :minor

          price = corporation.share_price
          index = price.corporations.find_index(@yellow_dummy) || price.corporations.find_index(@green_dummy)
          price.corporations.delete_at(index) if index

          @minor_prices[price.price] += 1
          corporation.reservation_color = self.class::FORMED_RESERVATION_COLOR if corporation.reservation_color
        end

        def place_home_token(corporation)
          buy_first_train(corporation)
          super
        end

        # minors formed in ISR auto-buy a train
        def buy_first_train(corporation)
          return if corporation.type != :minor || corporation.tokens.first&.used || !corporation.floated?
          return unless @turn == 1

          train = @depot.upcoming.first
          @log << "#{corporation.name} buys a #{train.name} train from Bank"
          buy_train(corporation, train)
        end

        def minor_yellow_prices
          @minor_yellow_prices ||=
            self.class::YELLOW_PRICES.flat_map do |p|
              [lookup_minor_price(p, self.class::BOTTOM_MINOR_ROW), lookup_minor_price(p, self.class::TOP_MINOR_ROW)]
            end
        end

        def minor_green_prices
          @minor_green_prices ||=
            self.class::GREEN_PRICES.flat_map do |p|
              [lookup_minor_price(p, self.class::BOTTOM_MINOR_ROW), lookup_minor_price(p, self.class::TOP_MINOR_ROW)]
            end
        end

        def share_prices
          (minor_yellow_prices + minor_green_prices + @stock_market.par_prices).uniq
        end

        def available_minor_prices
          available = @minor_yellow_prices.reject { |p| @minor_prices[p.price] > 1 }
          available.concat(@minor_green_prices.reject { |p| @minor_prices[p.price] > 1 }) if @phase.available?('3')
          available
        end

        def available_minor_par_prices
          available = @minor_yellow_prices.select { |p| p.corporations.include?(@yellow_dummy) }
          return available unless @phase.available?('3')

          available + minor_green_prices.select { |p| p.corporations.include?(@green_dummy) }
        end

        def status_array(corp)
          if corp.type == :major && corp.ipoed && !corp.ipo_shares.empty?
            return [["Par: #{format_currency(corp.original_par_price.price)}"]]
          end
          return if corp.type == :major
          return [['Minor Company'], ["Value: #{format_currency(corp.share_price.price)}"]] if corp.share_price
          return [["Reserved by #{@reserved[corp].name}", 'bold']] if @reserved[corp]
          return [['Minor Company']] if @starting_minors.include?(corp) || @phase.available?('3')

          [['Minor Company - Not Available', 'bold']]
        end

        def corporation_show_shares?(corp)
          corp.type != :minor
        end

        def operating_order
          @corporations.reject { |c| c.minor? || c.closed? }.select(&:floated?).sort.partition { |c| c.type == :minor }.flatten
        end

        def bank_sort(corporations)
          majors, minors = corporations.reject(&:minor?).partition { |c| c.type == :major }
          avail, unavail = minors.partition { |c| @phase.available?('3') || @starting_minors.include?(c) }

          avail.sort_by(&:name) + unavail.sort_by(&:name) + majors.sort_by(&:name)
        end

        def player_sort(entities)
          super(entities.select(&:corporation?))
        end

        def reserve_minor(minor, entity)
          @reserved[minor] = entity
          minor.reservation_color = self.class::RESERVED_RESERVATION_COLOR
        end

        def unreserve_minor(minor, _entity)
          @reserved.delete(minor)
          minor.reservation_color = self.class::START_RESERVATION_COLOR
        end

        def ipo_name(corp = nil)
          corp&.type == :minor ? 'Treasury' : 'IPO'
        end

        def ipo_verb(corp = nil)
          corp&.type == :minor ? 'forms' : 'pars'
        end

        def form_button_text(corp)
          "Reserve #{corp.name}"
        end

        def tile_lays(entity)
          return self.class::TILE_LAYS unless entity.type == :minor

          self.class::MINOR_TILE_LAYS
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          # handle special-case upgrades
          return true if force_upgrade?(from, to)

          super
        end

        def force_upgrade?(from, to)
          return false unless from.preprinted
          return false unless (list = self.class::PREPRINTED_UPGRADES[from.hex.coordinates])

          list.include?(to.name)
        end

        def stock_round_corporations
          corp_list = @corporations.select do |c|
            c.ipoed || (c.type == :minor && (@phase.available?('3') || @starting_minors.include?(c)))
          end
          majors, minors = corp_list.partition { |c| c.type == :major }
          formed, unformed = minors.partition(&:ipoed)
          majors.sort + unformed.sort + formed.sort
        end

        def can_par?(corporation, _entity)
          corporation.type == :minor &&
            !corporation.ipoed &&
            (@phase.available?('3') || @starting_minors.include?(corporation))
        end

        def merge_corporations
          @corporations.select { |c| c.type == :minor && c.ipoed }
        end

        def merge_rounds
          [G18NewEngland::Round::Merger]
        end

        def any_unstarted_majors?
          @corporations.any? { |c| c.type == :major && !c.ipoed }
        end

        def can_go_bankrupt?(_player, corporation)
          corporation.type != :minor && super
        end

        def redeemable_shares(entity)
          return [] if !entity.corporation? || entity.type == :minor

          bundles_for_corporation(share_pool, entity)
            .reject { |bundle| entity.cash < bundle.price }
        end

        def issuable_shares(entity)
          return [] if !entity.corporation? || entity.type == :minor

          treasury = bundles_for_corporation(entity, entity)
          ipo = bundles_for_corporation(@bank, entity)
          ipo.each { |b| b.share_price = entity.original_par_price.price }
          (treasury + ipo).reject do |bundle|
            (bundle.num_shares + entity.num_market_shares) * 10 > self.class::MARKET_SHARE_LIMIT
          end
        end

        def par_price_str(share_price)
          case share_price.coordinates.first
          when self.class::MAJOR_ROW
            format_currency(share_price.price)
          when self.class::TOP_MINOR_ROW
            "#{format_currency(share_price.price)}⇧"
          else
            "#{format_currency(share_price.price)}⇩"
          end
        end

        def close_corporation(corporation, quiet: false)
          share_price = corporation.share_price
          minor = corporation.type == :minor
          super
          return unless minor

          share_price.corporations << @closed_dummy
        end

        def express_train?(train)
          train.name.include?('E')
        end

        def check_distance(route, visits)
          return super unless express_train?(route.train)

          # express trains can ignore towns
          city_stops = visits.count { |node| node.city? || node.offboard? }
          raise GameError, 'Route has too many cities/offboards' if city_stops > route.train.distance
        end

        def check_other(route)
          visited_hexes = {}
          last_hex = nil
          route.visited_stops.each do |stop|
            hex = stop.hex
            raise GameError, 'Route cannot run to multiple unconnected cities in a hex' if hex != last_hex && visited_hexes[hex]

            visited_hexes[hex] = true
            last_hex = hex
          end
        end

        def compute_stops(route)
          return super unless express_train?(route.train)

          visits = route.visited_stops
          return [] if visits.empty?

          # no choice about citys/offboards => they must be stops
          stops = visits.select { |node| node.city? || node.offboard? }

          # unused city/offboard allowance can be used for towns by express trains
          t_allowance = route.train.distance - stops.size

          # pick highest revenue towns
          towns = visits.select(&:town?)
          num_towns = [t_allowance, towns.size].min
          stops.concat(towns.sort_by { |t| t.uniq_revenues.first }.reverse.take(num_towns)) if num_towns.positive?

          stops
        end

        def route_distance(route)
          route.stops.size
        end

        # reduce all express trains to the smallest one
        def route_trains(entity)
          return [] unless entity.corporation?

          express, normal = entity.trains.partition { |t| express_train?(t) }
          return normal if express.empty?

          min_express = express.min_by(&:distance)
          normal + [min_express]
        end

        def revenue_multiplier(train)
          return 1 unless express_train?(train)

          train.owner.trains.count { |t| express_train?(t) }
        end

        def revenue_for(route, stops)
          super * revenue_multiplier(route.train)
        end

        def revenue_str(route)
          multiplier = revenue_multiplier(route.train)
          super + (multiplier < 2 ? '' : " (×#{multiplier})")
        end

        def separate_treasury?
          true
        end

        def train_name(train)
          return train.name unless (multiplier = revenue_multiplier(train)) > 1

          "#{train.name}×#{multiplier}"
        end

        def available_programmed_actions
          [Action::ProgramMergerPass, Action::ProgramBuyShares, Action::ProgramSharePass]
        end
      end
    end
  end
end
