# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative '../../option_error'
require_relative '../../distance_graph'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1825
      class Game < Game::Base
        include_meta(G1825::Meta)
        include Entities
        include Map

        attr_reader :units, :distance_graph

        register_colors(black: '#37383a',
                        seRed: '#f72d2d',
                        bePurple: '#2d0047',
                        peBlack: '#000',
                        beBlue: '#c3deeb',
                        heGreen: '#78c292',
                        oegray: '#6e6966',
                        weYellow: '#ebff45',
                        beBrown: '#54230e',
                        gray: '#6e6966',
                        red: '#d81e3e',
                        turquoise: '#00a993',
                        blue: '#0189d1',
                        brown: '#7b352a')

        SMALL_MARKET = [
          %w[0c
             5y
             10y
             16y
             24y
             34y
             42y
             49y
             55
             61
             67p
             71p
             76p
             82p
             90p
             100p
             112
             126
             142
             160
             180
             205
             230
             255
             280
             300
             320
             340e],
        ].freeze

        LARGE_MARKET = [
          %w[0c
             5y
             10y
             16y
             24y
             34y
             42y
             49y
             55
             61
             67p
             71p
             76p
             82p
             90p
             100p
             112
             126
             142
             160
             180
             205
             230
             255
             280
             300
             320
             340
             360
             380
             400
             420
             440
             460
             480
             500e],
        ].freeze

        def game_market
          @units[2] ? LARGE_MARKET : SMALL_MARKET
        end

        COMMON_PHASES = [
          {
            name: '1',
            on: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '2',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        UNIT2_PHASES = [
          {
            name: '4a',
            on: '6',
            train_limit: 99,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        UNIT3_PHASES = [
          {
            name: '4b',
            on: '7',
            train_limit: 99,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        def game_phases
          gphases = COMMON_PHASES.dup
          gphases.concat(UNIT2_PHASES) if @units[2]
          gphases.concat(UNIT3_PHASES) if @units[3]
          gphases
        end

        # FIXME: 3T/4T/2+2/4+4E definition and/or handling
        ALL_TRAINS = {
          '2' => { distance: 2, price: 180, rusts_on: '5' },
          '3' => { distance: 3, price: 300, rusts_on: '7' },
          '4' => { distance: 4, price: 430 },
          '5' => { distance: 5, price: 550 },
          '3T' => { distance: 3, price: 370, available_on: '3' },
          'U3' => { distance: 3, price: 410, available_on: '3' },
          '4T' => { distance: 3, price: 480, available_on: '6' },
          '2+2' => { distance: 2, price: 600, available_on: '6' },
          '6' => { distance: 7, price: 650 },
          '7' => { distance: 7, price: 720 },
          '4+4E' => { distance: 4, price: 830, available_on: '7' },
        }.freeze

        def build_train_list(thash)
          thash.keys.map do |t|
            new_hash = {}
            new_hash[:name] = t
            new_hash[:num] = thash[t]
            new_hash.merge!(ALL_TRAINS[t])
          end
        end

        # FIXME: add option for additonal 3T/U3 for Unit 3
        # FIXME: add K2 trains
        # FIXME: add K3 trains
        def game_trains
          case @units.keys.sort.map(&:to_s).join
          when '1'
            build_train_list({ '2' => 6, '3' => 4, '4' => 3, '5' => 4 })
          when '2'
            build_train_list({ '2' => 5, '3' => 3, '4' => 2, '5' => 3, '6' => 2 })
          when '3'
            # extra 5/3T/U3 for minors
            build_train_list({ '2' => 5, '3' => 3, '4' => 1, '5' => 3, '7' => 2, '3T' => 1, 'U3' => 1 })
          when '12'
            build_train_list({ '2' => 7, '3' => 6, '4' => 4, '5' => 5, '6' => 2 })
          when '23'
            # extra 5/3T/U3 for minors
            build_train_list({ '2' => 5, '3' => 5, '4' => 4, '5' => 6, '6' => 2, '7' => 2, '3T' => 1, 'U3' => 1 })
          else # all units
            # extra 5/3T/U3 for minors
            build_train_list({ '2' => 7, '3' => 6, '4' => 5, '5' => 6, '6' => 2, '7' => 2, '3T' => 1, 'U3' => 1 })
          end
        end

        CURRENCY_FORMAT_STR = '£%d'
        CAPITALIZATION = :full
        MUST_SELL_IN_BLOCKS = false
        SELL_MOVEMENT = :none
        SELL_BUY_ORDER = :sell_buy_sell
        SOLD_OUT_INCREASE = false
        PRESIDENT_SALES_TO_MARKET = true
        HOME_TOKEN_TIMING = :operating_round
        BANK_CASH = 50_000
        COMPANY_SALE_FEE = 30
        TRACK_RESTRICTION = :restrictive
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze

        def blocker_companies
          corporations
        end

        def init_optional_rules(optional_rules)
          optional_rules = (optional_rules || []).map(&:to_sym)

          if optional_rules.empty?
            case @players.size
            when 2
              optional_rules << :unit_3
              @log << 'Using Unit 3 based on player count'
            when 3
              optional_rules << :unit_2
              @log << 'Using Unit 2 based on player count'
            when 4, 5
              optional_rules << :unit_1
              @log << 'Using Unit 1 based on player count'
            when 6, 7
              optional_rules << :unit_12
              @log << 'Using Units 1+2 based on player count'
            when 8, 9
              optional_rules << :unit_123
              @log << 'Using Units 1+2+3 based on player count'
            end
          end

          if optional_rules.include?(:unit_1) && optional_rules.include?(:unit_2) &&
              optional_rules.include?(:unit_3)
            optional_rules.delete(:unit_1)
            optional_rules.delete(:unit_2)
            optional_rules.delete(:unit_3)
            optional_rules << :unit_123
          elsif optional_rules.include?(:unit_1) && optional_rules.include?(:unit_2)
            optional_rules.delete(:unit_1)
            optional_rules.delete(:unit_2)
            optional_rules << :unit_12
          elsif optional_rules.include?(:unit_2) && optional_rules.include?(:unit_3)
            optional_rules.delete(:unit_2)
            optional_rules.delete(:unit_3)
            optional_rules << :unit_23
          end

          # sanity check player count and illegal combination of options
          @units = {}

          @units[1] = true if optional_rules.include?(:unit_1)
          @units[1] = true if optional_rules.include?(:unit_12)
          @units[1] = true if optional_rules.include?(:unit_123)

          @units[2] = true if optional_rules.include?(:unit_2)
          @units[2] = true if optional_rules.include?(:unit_12)
          @units[2] = true if optional_rules.include?(:unit_23)
          @units[2] = true if optional_rules.include?(:unit_123)

          @units[3] = true if optional_rules.include?(:unit_3)
          @units[3] = true if optional_rules.include?(:unit_23)
          @units[3] = true if optional_rules.include?(:unit_123)

          raise OptionError, 'Cannot combine Units 1 and 3 without Unit 2' if @units[1] && !@units[2] && @units[3]

          # FIXME: update for regional kits when added
          p_range = case @units.keys.sort.map(&:to_s).join
                    when '1'
                      [2, 5]
                    when '2'
                      [2, 4]
                    when '3'
                      [2]
                    when '12'
                      [3, 7]
                    when '23'
                      [3, 5]
                    else # all units
                      [4, 8]
                    end
          if p_range.first > @players.size || p_range.last < @players.size
            raise OptionError, 'Invalid option(s) for number of players'
          end

          optional_rules
        end

        def bank_by_options
          @bank_by_options ||=
            case @units.keys.sort.map(&:to_s).join
            when '1'
              6_000
            when '2'
              5_000
            when '3'
              4_000
            when '12'
              11_000
            when '23'
              9_000
            else # all units
              15_000
            end
        end

        def cash_by_options
          case @units.keys.sort.map(&:to_s).join
          when '1'
            { 2 => 1200, 3 => 830, 4 => 630, 5 => 504 }
          when '2'
            { 2 => 1200, 3 => 800, 4 => 600 }
          when '3'
            { 2 => 750 }
          when '12'
            { 3 => 840, 4 => 630, 5 => 504, 6 => 420, 7 => 360 }
          when '23'
            { 3 => 840, 4 => 630, 5 => 504 }
          else # all units
            { 4 => 630, 5 => 504, 6 => 420, 7 => 360, 8 => 315, 9 => 280 }
          end
        end

        def certs_by_options
          case @units.keys.sort.map(&:to_s).join
          when '1'
            { 2 => 24, 3 => 16, 4 => 12, 5 => 10 }
          when '2'
            { 2 => 24, 3 => 16, 4 => 12 }
          when '3'
            { 2 => 17 }
          when '12'
            { 3 => 31, 4 => 23, 5 => 19, 6 => 16, 7 => 14 }
          when '23'
            { 3 => 29, 4 => 23, 5 => 18 }
          else # all units
            { 4 => 33, 5 => 28, 6 => 23, 7 => 19, 8 => 17, 9 => 15 }
          end
        end

        def init_bank
          # amount doesn't matter here
          Bank.new(BANK_CASH, log: @log, check: false)
        end

        def bank_cash
          bank_by_options - @players.sum(&:cash)
        end

        def check_bank_broken!
          @bank.break! if bank_cash.negative?
        end

        def init_starting_cash(players, bank)
          cash = cash_by_options[players.size]
          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def init_cert_limit
          certs_by_options[players.size]
        end

        def init_share_pool
          SharePool.new(self, allow_president_sale: true)
        end

        def setup
          @distance_graph = DistanceGraph.new(self, separate_node_types: false)
          @formed = []
          @highest_layer = 0
          @layer_by_corp = {}

          pars = @corporations.map { |c| PAR_BY_CORPORATION[c.name] }.compact.uniq.sort.reverse
          @corporations.each do |corp|
            next unless PAR_BY_CORPORATION[corp.name]

            @layer_by_corp[corp] = pars.index(PAR_BY_CORPORATION[corp.name]) + 1
          end

          @minor_trigger_layer = pars.include?(71) ? pars.index(71) + 2 : pars.index(76) + 2

          # Distribute privates
          # Rules call for randomizing privates, assigning to players then reordering players
          # based on worth of private
          # Instead, just pass out privates from least to most expensive since player order is already
          # random. Throw in LNWR pres shares then LNWR reg shares when out of companies (not an issue when
          # playing with just Unit 3 since it only supports 2 players).
          sorted_companies = @companies.sort_by(&:value)
          size = sorted_companies.size
          @players.each_with_index do |player, idx|
            if idx < size
              company = sorted_companies.shift
              @log << "#{player.name} receives #{company.name} and pays #{format_currency(company.value)}"
              player.spend(company.value, @bank)
              player.companies << company
              company.owner = player
            elsif idx == size
              lnwr = corporation_by_id('LNWR')
              price = par_prices(lnwr).first
              @stock_market.set_par(lnwr, price)
              share = lnwr.ipo_shares.first
              @share_pool.buy_shares(player, share.to_bundle, exchange: nil, swap: nil, allow_president_change: true)
              after_par(lnwr)
            else
              lnwr = corporation_by_id('LNWR')
              share = lnwr.ipo_shares.find { |s| !s.owner&.player? }
              @share_pool.buy_shares(player, share.to_bundle, exchange: nil, swap: nil, allow_president_change: true)
            end
          end
          @highest_layer = 1 if unbought_companies.empty?
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          # handle special-case upgrades
          return true if force_dit_upgrade?(from, to)

          super
        end

        def force_dit_upgrade?(from, to)
          return false unless (list = DIT_UPGRADES[from.name])

          list.include?(to.name)
        end

        def can_ipo?(corp)
          if @layer_by_corp[corp]
            @layer_by_corp[corp] <= current_layer
          else
            @minor_trigger_layer <= current_layer
          end
        end

        def major?(corp)
          corp.presidents_share.percent == 20
        end

        def minor?(corp)
          corp.presidents_share.percent != 20
        end

        def minor_required_train(corp)
          return unless minor?(corp)

          rtrain = REQUIRED_TRAIN[corp.name]
          @depot.trains.find { |t| t.name == rtrain }
        end

        def minor_par_prices(corp)
          price = minor_required_train(corp).price
          stock_market.market.first.select { |p| (p.price * 10) > price }.reject { |p| p.type == :endgame }
        end

        def par_prices(corp)
          if major?(corp)
            price = PAR_BY_CORPORATION[corp.name]
            stock_market.par_prices.select { |p| p.price == price }
          else
            minor_par_prices(corp)
          end
        end

        def check_new_layer
          layer = current_layer
          @log << "-- Band #{layer} corporations now available --" if layer > @highest_layer
          @highest_layer = layer
        end

        def current_layer
          # undistributed privates must be sold before any corps
          return 0 if @companies.any? { |c| !c.owner && c.abilities.empty? }

          layers = @layer_by_corp.select do |corp, _layer|
            corp.num_ipo_shares.zero?
          end.values
          layers.empty? ? 1 : [layers.max + 1, 4].min
        end

        def init_round
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter += 1
          stock_round
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1825::Step::BuySellParSharesCompanies,
          ])
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            G1825::Step::TrackAndToken,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
          ], round_num: round_num)
        end

        # Formation isn't flotation for minors
        def formed?(corp)
          @formed.include?(corp)
        end

        def check_formation(corp)
          return if formed?(corp)

          if major?(corp)
            @formed << corp if corp.floated?
          elsif corp.cash >= minor_required_train(corp).price
            # note, not flotation, but when minor can purchase its required train
            @formed << corp
          end
        end

        # -1 if a has a higher par price than b
        # 1 if a has a lower par price than b
        # if they are the same, then use the order of formation (generally flotation)
        def par_compare(a, b)
          if a.par_price.price > b.par_price.price
            -1
          elsif a.par_price.price < b.par_price.price
            1
          else
            @formed.find_index(a) < @formed.find_index(b) ? -1 : 1
          end
        end

        def operating_order
          @corporations.select { |c| formed?(c) }.sort { |a, b| par_compare(a, b) }.partition { |c| major?(c) }.flatten
        end

        def unbought_companies
          @companies.select { |c| !c.closed? && !c.owner }
        end

        def buyable_bank_owned_companies
          if (unbought = unbought_companies).empty?
            @companies.select { |c| !c.closed? && (!c.owner || c.owner == @bank) }
          else
            [unbought.min_by(&:value)]
          end
        end

        def sorted_corporations
          @corporations.sort_by { |c| @layer_by_corp[c] || @minor_trigger_layer }
        end

        def corporation_available?(entity)
          entity.corporation? && can_ipo?(entity)
        end

        def status_array(corp)
          if @layer_by_corp[corp]
            layer_str = "Band #{@layer_by_corp[corp]}"
            layer_str += ' (N/A)' unless can_ipo?(corp)

            prices = par_prices(corp).map(&:price).sort
            par_str = ("Par #{prices[0]}" unless corp.ipoed)
          else
            layer_str = "Band #{@minor_trigger_layer}"
            layer_str += ' (N/A)' unless can_ipo?(corp)

            prices = par_prices(corp).map(&:price).sort
            par_str = ("Par #{prices[0]}-#{prices[-1]}" unless corp.ipoed)
          end

          status = []
          status << %w[Minor bold] unless @layer_by_corp[corp]
          status << ["Required Train: #{minor_required_train(corp).name}"] if !@layer_by_corp[corp] && corp.trains.empty?
          status << [layer_str]
          status << [par_str] if par_str
          status << %w[Receivership bold] if corp.receivership?

          status
        end

        # FIXME: change after implementing trains with non-scalar distances
        def biggest_train_distance(entity)
          return 0 if entity.trains.empty?

          entity.trains.map(&:distance).max
        end
      end
    end
  end
end
