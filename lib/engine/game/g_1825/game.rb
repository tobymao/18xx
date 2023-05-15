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

        attr_reader :units, :node_distance_graph, :city_distance_graph

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

        UNIT2_PHASES_NO_K3 = [
          {
            name: '3a',
            on: '6',
            train_limit: 3,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        PHASES_K3 = [
          {
            name: '4',
            on: '6',
            train_limit: 99,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '4a',
            on: '7',
            train_limit: 99,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        def game_phases
          gphases = COMMON_PHASES.dup
          gphases.concat(UNIT2_PHASES_NO_K3) if @units[2] && !@kits[3]
          gphases.concat(PHASES_K3) if @kits[3]
          gphases
        end

        ALL_TRAINS = {
          '2' => { distance: 2, price: 180, rusts_on: '5' },
          '3' => { distance: 3, price: 300 },
          '4' => { distance: 4, price: 430 },
          '5' => { distance: 5, price: 550 },
          '6' => { distance: 6, price: 650 },
          '7' => { distance: 7, price: 720 },
          '3T' => { distance: 3, price: 370, available_on: '3' },
          'U3' => {
            distance: [{ 'nodes' => ['city'], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 410,
            available_on: '3',
          },
          '4T' => { distance: 4, price: 480, available_on: '4' },
          '2+2' => { distance: 2, price: 600, multiplier: 2, available_on: '4' },
          '4+4E' => {
            distance: [{ 'nodes' => ['city'], 'pay' => 4, 'visit' => 99 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 830,
            multiplier: 2,
            available_on: '4a',
          },
        }.freeze

        ALL_TRAINS_K3 = {
          '2' => { distance: 2, price: 180, rusts_on: '5' },
          '3' => { distance: 3, price: 300, rusts_on: '7' },
          '4' => { distance: 4, price: 430 },
          '5' => { distance: 5, price: 550 },
          '6' => { distance: 6, price: 650 },
          '7' => { distance: 7, price: 720 },
          '3T' => { distance: 3, price: 370, available_on: '3' },
          'U3' => {
            distance: [{ 'nodes' => ['city'], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
            price: 410,
            available_on: '3',
          },
          '4T' => { distance: 4, price: 480, available_on: '4' },
          '2+2' => { distance: 2, price: 600, multiplier: 2, available_on: '4' },
          '4+4E' => {
            distance: [{ 'nodes' => ['city'], 'pay' => 4, 'visit' => 99 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 830,
            multiplier: 2,
            available_on: '4a',
          },
        }.freeze

        DUMMY_TRAINS = [
          { name: '2', price: 1, distance: [{ 'nodes' => %w[city town], 'pay' => 2, 'visit' => 2 }] },
          { name: '3', price: 1, distance: [{ 'nodes' => %w[city town], 'pay' => 3, 'visit' => 3 }] },
          { name: '4', price: 1, distance: [{ 'nodes' => %w[city town], 'pay' => 4, 'visit' => 4 }] },
          { name: '5', price: 1, distance: [{ 'nodes' => %w[city town], 'pay' => 5, 'visit' => 5 }] },
          { name: '3T', price: 1, distance: [{ 'nodes' => %w[city town], 'pay' => 3, 'visit' => 3 }] },
          {
            name: 'U3',
            price: 1,
            distance: [{ 'nodes' => ['city'], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 99, 'visit' => 99 }],
          },
          { name: '6', price: 1, distance: [{ 'nodes' => %w[city town], 'pay' => 6, 'visit' => 6 }] },
          { name: '4T', price: 1, distance: [{ 'nodes' => %w[city town], 'pay' => 4, 'visit' => 4 }] },
          { name: '2+2', price: 1, distance: [{ 'nodes' => %w[city town], 'pay' => 2, 'visit' => 2 }] },
          { name: '7', price: 1, distance: [{ 'nodes' => %w[city town], 'pay' => 7, 'visit' => 7 }] },
        ].freeze

        def build_train_list(thash)
          thash.keys.map do |t|
            new_hash = {}
            new_hash[:name] = t
            new_hash[:num] = thash[t]
            new_hash.merge!(ALL_TRAINS[t]) unless @kits[3]
            new_hash.merge!(ALL_TRAINS_K3[t]) if @kits[3]
            new_hash
          end
        end

        def add_train_list(tlist, thash)
          thash.keys.each do |t|
            if (item = tlist.find { |h| h[:name] == t })
              item[:num] += thash[t]
            else
              new_hash = {}
              new_hash[:name] = t
              new_hash[:num] = thash[t]
              new_hash.merge!(ALL_TRAINS[t]) unless @kits[3]
              new_hash.merge!(ALL_TRAINS_K3[t]) if @kits[3]

              tlist << new_hash
            end
          end
        end

        # throw out available_on specifiers if that phase isn't in this game
        # this should only apply to minor trains
        def fix_train_availables(tlist)
          phase_list = %w[1 2 3]
          phase_list << '3a' if @units[2] && !@kits[3]
          phase_list.concat(%w[4 4a]) if @kits[3]
          tlist.each do |h|
            h.delete(:available_on) if h[:available_on] && !phase_list.include?(h[:available_on])
          end
        end

        # FIXME: add option for additonal 3T/U3 for Unit 3
        def game_trains
          trains = build_train_list({
                                      '2' => 0,
                                      '3' => 0,
                                      '4' => 0,
                                      '5' => 0,
                                      '6' => 0,
                                      '7' => 0,
                                      '3T' => 0,
                                      'U3' => 0,
                                      '2+2' => 0,
                                      '4T' => 0,
                                      '4+4E' => 0,
                                    })

          case @units.keys.sort.map(&:to_s).join
          when '1'
            add_train_list(trains, { '2' => 6, '3' => 4, '4' => 3, '5' => 4  })
          when '2'
            add_train_list(trains, { '2' => 5, '3' => 3, '4' => 2, '5' => 3, '6' => 2 })
          when '3'
            # extra 5/3T/U3 for minors
            add_train_list(trains, { '2' => 5, '3' => 3, '4' => 1, '5' => 3, '7' => 2, '3T' => 1, 'U3' => 1 })
          when '12'
            add_train_list(trains, { '2' => 7, '3' => 6, '4' => 4, '5' => 5, '6' => 2, '7' => 0 })
          when '23'
            # extra 5/3T/U3 for minors
            add_train_list(trains, { '2' => 5, '3' => 5, '4' => 4, '5' => 6, '7' => 2, '3T' => 1, 'U3' => 1 })
          else # all units
            # extra 5/3T/U3 for minors
            add_train_list(trains, { '2' => 7, '3' => 6, '4' => 5, '5' => 6, '6' => 2, '7' => 2, '3T' => 1, 'U3' => 1 })
          end

          add_train_list(trains, { '3T' => 2, 'U3' => 2 }) if @optional_rules.include?(:u3p)
          add_train_list(trains, { 'U3' => 1, '4T' => 1 }) if @regionals[1]
          add_train_list(trains, { '5' => 1 }) if @regionals[2]
          add_train_list(trains, { '4T' => 1 }) if @regionals[3]
          add_train_list(trains, { '5' => -1, '6' => 3, '7' => 2 }) if @kits[3]
          add_train_list(trains, { '5' => 1, '3T' => 1 }) if @kits[5]
          add_train_list(trains, { '2+2' => 1 }) if @kits[7]

          # handle K2
          if @kits[2]
            case @units.keys.sort.map(&:to_s).join
            when '1', '2'
              add_train_list(trains, { '3T' => 3, 'U3' => 1, '2+2' => 3, '4T' => 2, '4+4E' => 2 })
              add_train_list(trains, { '3' => -1, '4' => -1 }) if @kits[3]
            when '12'
              add_train_list(trains, { '3T' => 4, 'U3' => 2, '2+2' => 3, '4T' => 2, '4+4E' => 2 })
              add_train_list(trains, { '3' => -1, '4' => -1, '5' => -1 }) if @kits[3]
            when '23'
              add_train_list(trains, { '3T' => 4, 'U3' => 2, '2+2' => 3, '4T' => 2, '4+4E' => 2 })
              add_train_list(trains, { '3' => -1, '5' => -1 }) if @kits[3]
            when '123'
              add_train_list(trains, { '3T' => 5, 'U3' => 3, '2+2' => 3, '4T' => 2, '4+4E' => 2 })
              add_train_list(trains, { '3' => -1, '4' => -1, '5' => -1 }) if @kits[3]
            end
          end

          fix_train_availables(trains)

          trains
        end

        CURRENCY_FORMAT_STR = '£%s'
        CAPITALIZATION = :full
        MUST_SELL_IN_BLOCKS = false
        SELL_MOVEMENT = :none
        SELL_BUY_ORDER = :sell_buy_sell
        SOLD_OUT_INCREASE = false
        PRESIDENT_SALES_TO_MARKET = true
        MARKET_SHARE_LIMIT = 100
        HOME_TOKEN_TIMING = :operating_round
        BANK_CASH = 50_000
        COMPANY_SALE_FEE = 30
        TRACK_RESTRICTION = :station_restrictive
        TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }].freeze
        GAME_END_CHECK = { bank: :current_or, stock_market: :immediate }.freeze
        TRAIN_PRICE_MIN = 10
        IMPASSABLE_HEX_COLORS = %i[blue sepia red].freeze
        TILE_200 = '200'

        TILE200_HEXES = %w[Q11 T16 V14].freeze

        BANK_UNIT1 = 5000
        BANK_UNIT2 = 5000
        BANK_UNIT3 = 4000

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
            when 8
              optional_rules << :unit_123
              @log << 'Using Units 1+2+3 based on player count'
            else
              optional_rules.concat(%i[unit_123 r1 r2 r3])
              @log << 'Using Units 1+2+3 and R1+R2+R3 based on player count'
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
          @kits = {}
          @regionals = {}

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

          @kits[1] = true if optional_rules.include?(:k1)
          @kits[2] = true if optional_rules.include?(:k2)
          @kits[3] = true if optional_rules.include?(:k3)
          @kits[5] = true if optional_rules.include?(:k5)
          @kits[6] = true if optional_rules.include?(:k6)
          @kits[7] = true if optional_rules.include?(:k7)

          @regionals[1] = true if optional_rules.include?(:r1)
          @regionals[2] = true if optional_rules.include?(:r2)
          @regionals[3] = true if optional_rules.include?(:r3)

          raise OptionError, 'Must select at least one Unit if using other options' if !@units[1] && !@units[2] && !@units[3]
          raise OptionError, 'Cannot combine Units 1 and 3 without Unit 2' if @units[1] && !@units[2] && @units[3]
          raise OptionError, 'Cannot add Regionals without Unit 1' if !@regionals.keys.empty? && !@units[1]
          raise OptionError, 'Cannot add K5 without Unit 2' if @kits[5] && !@units[2]
          raise OptionError, 'Cannot add K7 without Unit 1' if @kits[7] && !@units[1]
          raise OptionError, 'K2 not supported with just Unit 3' if @kits[2] && !@units[1] && !@units[2] && @units[3]
          raise OptionError, 'K2 not supported without K3' if @kits[2] && !@kits[3]
          raise OptionError, 'Cannot use extra Unit 3 trains without Unit 3' if !@units[3] && optional_rules.include?(:u3p)
          raise OptionError, 'Cannot use K1 or K6 with D1' if (@kits[1] || @kits[6]) && optional_rules.include?(:d1)
          if !units[1] && !units[3] && optional_rules.include?(:db1)
            raise OptionError, 'Variant DB1 not useful in a Unit 2 only game'
          end
          raise OptionError, 'Variant DB2 is for Unit 1' if !units[1] && optional_rules.include?(:db2)
          raise OptionError, 'Variant DB3 is for Unit 3' if !units[3] && optional_rules.include?(:db3)
          raise OptionError, 'Unit 4 requires Unit 3' if optional_rules.include?(:unit_4) && !units[3]

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
                      @regionals.empty? ? [4, 8] : [4, 9]
                    end
          if (p_range.first > @players.size || p_range.last < @players.size) && @players.size.positive?
            raise OptionError, 'Invalid option(s) for number of players'
          end

          optional_rules
        end

        def calculate_bank_cash
          bank_cash = 0
          if @optional_rules.include?(:big_bank)
            bank_cash += BANK_UNIT1 if @units[1]
            bank_cash += BANK_UNIT2 if @units[2]
            bank_cash += BANK_UNIT3 if @units[3]
          else
            bank_cash = BANK_UNIT1 if @units[1]
            bank_cash = BANK_UNIT2 if @units[2] && bank_cash.zero?
            bank_cash = BANK_UNIT3 if @units[3] && bank_cash.zero?
          end

          # add in minor and kit changes (Mike Hutton clarification)
          unless @optional_rules.include?(:strict_bank)
            bank_cash += 2000 if @kits[2]
            bank_cash += 2000 if @kits[3]
            bank_cash += 1000 * num_minors
          end

          bank_cash
        end

        def bank_by_options
          @bank_by_options ||= calculate_bank_cash
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

        def num_minors
          num_minors = 0
          num_minors += 2 if @regionals[1]
          num_minors += 1 if @regionals[2]
          num_minors += 1 if @regionals[2]
          num_minors += 2 if @kits[5]
          num_minors += 1 if @kits[7]
          num_minors
        end

        def adjust_certs(certs, chash)
          chash.keys.each do |nplayers|
            if certs[nplayers]
              certs[nplayers] += chash[nplayers]
            else
              certs[nplayers] = chash[nplayers]
            end
          end
        end

        def certs_by_options
          certs = case @units.keys.sort.map(&:to_s).join
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

          case num_minors
          when 1
            adjust_certs(certs, { 2 => 1, 3 => 1, 4 => 1 })
          when 2
            adjust_certs(certs, { 2 => 2, 3 => 2, 4 => 1, 5 => 1, 6 => 1 })
          when 3
            adjust_certs(certs, { 2 => 3, 3 => 2, 4 => 2, 5 => 2, 6 => 1, 7 => 1, 8 => 1, 9 => 1 })
          when 4
            adjust_certs(certs, { 2 => 4, 3 => 3, 4 => 2, 5 => 2, 6 => 2, 7 => 2, 8 => 1, 9 => 1 })
          when 5
            adjust_certs(certs, { 2 => 5, 3 => 4, 4 => 3, 5 => 2, 6 => 2, 7 => 2, 8 => 2, 9 => 1 })
          when 6
            adjust_certs(certs, { 3 => 5, 4 => 3, 5 => 3, 6 => 3, 7 => 2, 8 => 2, 9 => 1 })
          when 7
            adjust_certs(certs, { 3 => 5, 4 => 4, 5 => 3, 6 => 3, 7 => 2, 8 => 2, 9 => 2 })
          end

          certs
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

        def setup
          @log << "Bank starts with #{format_currency(bank_by_options)}"

          @node_distance_graph = DistanceGraph.new(self, separate_node_types: false)
          @city_distance_graph = DistanceGraph.new(self, separate_node_types: true)
          @formed = []
          @highest_layer = 0
          @layer_by_corp = {}

          @par_by_corporation = game_par_values

          pars = @corporations.map { |c| @par_by_corporation[c.name] }.compact.uniq.sort.reverse
          @corporations.each do |corp|
            next unless @par_by_corporation[corp.name]

            @layer_by_corp[corp] = pars.index(@par_by_corporation[corp.name]) + 1
          end
          @minor_trigger_layer = pars.include?(71) ? pars.index(71) + 2 : pars.index(76) + 2
          @max_layers = @layer_by_corp.values.max
          @max_layers = [@max_layers, @minor_trigger_layer].max if @units[3] || num_minors.positive?

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

          # pull out minor trains from depot
          @minor_trains = []
          corporations.each do |minor|
            next unless (name = REQUIRED_TRAIN[minor.name])

            req_train = @depot.upcoming.find { |t| t.name == name }
            raise GameError, "Unable to find train #{name} for minor #{minor.name}" unless req_train

            req_train.buyable = false
            req_train.reserved = true
            @minor_trains << req_train
            @depot.remove_train(req_train)
          end

          # pre-allocate dummy trains used for tile 200
          @pass_thru = {}
          DUMMY_TRAINS.each { |train| @pass_thru[train[:name]] = Train.new(**train, requires_token: false, index: 999) }
        end

        # cache all stock prices
        def share_prices
          stock_market.market.first
        end

        def active_players
          players_ = @round.active_entities.map(&:player).compact

          players_.empty? ? acting_when_empty : players_
        end

        def acting_when_empty
          if (active_entity = @round && @round.active_entities[0])
            [acting_for_entity(active_entity)]
          else
            @players
          end
        end

        # for receivership:
        # find first player from PD not a director
        # o.w. PD
        def acting_for_entity(entity)
          return entity if entity.player?
          return entity.owner if entity.owner.player?

          acting = @players.find { |p| !director?(p) }
          acting || @players.first
        end

        def director?(player)
          @corporations.any? { |c| c.owner == player }
        end

        def tile_valid_for_phase?(tile, hex: nil, phase_color_cache: nil)
          phase_color_cache ||= @phase.tiles

          # 119 upgrades from yellow in phase 3
          return false if tile.name == '119' && !phase_color_cache.include?(:brown)

          # 166 upgrades from green in phase 4
          return false if tile.name == '166' && !phase_color_cache.include?(:gray)

          phase_color_cache.include?(tile.color)
        end

        def location_name(coord)
          @location_names ||= game_location_names
          @location_names[coord]
        end

        def game_location_names
          locations = LOCATION_NAMES.dup
          if optional_rules.include?(:unit_4)
            locations['A5'] = 'Inverness'
            locations['C3'] = 'Fort William'
            locations.delete('B8')
          end
          locations['G7'] = if optional_rules.include?(:db3)
                              'Falkirk & Airdrie'
                            else
                              'Coatbridge & Airdrie'
                            end
          locations
        end

        def upgrades_to?(from, to, special = false, selected_company: nil)
          # handle special-case upgrades
          return true if force_upgrade?(from, to)
          return false if illegal_upgrade?(from, to) # only really needed for upgrades shown on tile manifest

          # deal with striped tiles
          # 119 upgrades from yellow in phase 3, and upgrades to gray
          return false if from.name == '119' && to.color == :brown
          # 166 upgrades from green in phase 4, but doesn't upgrade
          return false if from.name == '166'
          # 200 upgrades from pre-printed brown tiles on Crewe, Wolverton or Swindon, doesn't upgrade
          return false if from.name == '200'
          return false if to.name == '200' && from.color != :sepia
          return true if to.name == '200' && TILE200_HEXES.include?(from.hex&.id)

          super
        end

        def force_upgrade?(from, to)
          return false unless (list = EXTRA_UPGRADES[from.name])

          list.include?(to.name)
        end

        def illegal_upgrade?(from, to)
          return false unless (list = ILLEGAL_UPGRADES[from.name])

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
          corp&.corporation? && corp.presidents_share.percent == 20
        end

        def minor?(corp)
          corp&.corporation? && corp.presidents_share.percent != 20
        end

        def minor_required_train(corp)
          return unless minor?(corp)

          rtrain = REQUIRED_TRAIN[corp.name]
          @depot.trains.find { |t| t.name == rtrain }
        end

        def minor_get_train(corp)
          return unless minor?(corp)

          rtrain = REQUIRED_TRAIN[corp.name]
          @minor_trains.find { |t| t.name == rtrain }
        end

        # minor share price is for a 10% share
        def minor_par_prices(corp)
          price = minor_required_train(corp).price
          stock_market.market.first.select { |p| (p.price * 10) > price }.reject { |p| p.type == :endgame }
        end

        def par_prices(corp)
          if major?(corp)
            price = @par_by_corporation[corp.name]
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
          layers.empty? ? 1 : [layers.max + 1, @max_layers].min
        end

        def minor_deferred_token?(entity)
          minor?(entity) && !entity.tokens.first&.used
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
          G1825::Round::Operating.new(self, [
            Engine::Step::HomeToken,
            G1825::Step::TrackAndToken,
            G1825::Step::Route,
            G1825::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1825::Step::BuyTrain,
          ], round_num: round_num)
        end

        # Minors need to have a tile with cities and paths before they can lay
        # their home token
        def can_place_home_token?(entity)
          return true unless minor?(entity)

          home_hex = hex_by_id(entity.coordinates)
          raise GameError, "can't find home hex for #{entity.name}" unless home_hex

          !home_hex.tile.paths.empty? && !home_hex.tile.cities.empty?
        end

        def place_home_token(corporation)
          return if corporation.tokens.first&.used
          return unless can_place_home_token?(corporation)

          unless corporation.coordinates.is_a?(Array)
            super
            @graph.clear
            return
          end

          corporation.coordinates.each do |coord|
            hex = hex_by_id(coord)
            next unless hex

            tile = hex&.tile
            next unless tile

            cities = tile.cities
            city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
            next unless city

            token = corporation.find_token_by_type

            @log << "#{corporation.name} places a token on #{hex.name}"
            city.place_token(corporation, token)
          end
          @graph.clear
        end

        # Formation isn't flotation for minors
        def formed?(corp)
          @formed.include?(corp)
        end

        # For minors: not flotation, but when minor can purchase its required train
        def check_formation(corp)
          return if formed?(corp)

          if major?(corp) && corp.floated?
            @formed << corp
            @log << "#{corp.name} forms"
          elsif minor?(corp) && corp.cash >= minor_required_train(corp).price
            @formed << corp
            @log << "Minor #{corp.name} forms"

            # buy required train (no phase-change side-effects)
            r_train = minor_get_train(corp)
            @minor_trains.delete(r_train)
            corp.trains << r_train
            r_train.owner = corp
            corp.spend(r_train.price, @bank)
            @log << "Minor #{corp.name} spends #{format_currency(r_train.price)} for required train (#{r_train.name})"
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

        def silent_receivership?(entity)
          entity.corporation? && entity.receivership? && minor?(entity) && (@units[1] || @units[2])
        end

        def can_run_route?(entity)
          super && !silent_receivership?(entity)
        end

        def status_array(corp)
          if major?(corp)
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
          status << %w[Minor bold] unless major?(corp)
          if minor?(corp) && !formed?(corp)
            train = minor_required_train(corp)
            status << ["Train: #{train.name} (#{format_currency(train.price)})"]
          end
          status << [layer_str]
          status << [par_str] if par_str
          status << %w[Receivership bold] if corp.receivership?

          status
        end

        def leaseable_trains
          @depot.depot_trains
        end

        def node_distance(train)
          return 0 if train.name == 'U3'

          train.distance.is_a?(Numeric) ? train.distance : 99
        end

        def biggest_node_distance(entity, leased = nil)
          return 0 if entity.trains.empty? && !leased
          return node_distance(leased) if leased

          biggest = entity.trains.map { |t| node_distance(t) }.max
          return 3 if biggest == 2 & entity.trains.count { |t| t.distance == 2 } > 1

          biggest
        end

        def city_distance(train)
          return 0 unless train.name == 'U3'

          3
        end

        def biggest_city_distance(entity, leased = nil)
          return 0 if entity.trains.empty? && !leased
          return city_distance(leased) if leased

          entity.trains.map { |t| city_distance(t) }.max
        end

        def route_trains(entity)
          (super + [@round.leased_train]).compact
        end

        def train_owner(train)
          train&.owner == @depot ? current_entity : train&.owner
        end

        def double_header_pair?(a, b)
          corporation = train_owner(a.train)
          return false if (common = (a.visited_stops & b.visited_stops)).empty?

          common = common.first
          return false if common.city? && common.blocks?(corporation)

          # Neither route can have two towns
          return false if a.visited_stops.all?(&:town?) || b.visited_stops.all?(&:town?)

          a_tokened = a.visited_stops.any? { |n| city_tokened_by?(n, corporation) }
          b_tokened = b.visited_stops.any? { |n| city_tokened_by?(n, corporation) }
          return false if !a_tokened && !b_tokened
          return true if common.town?

          !(a_tokened && b_tokened)
        end

        # look for pairs of 2-trains that:
        # - have exactly two visited nodes each
        # - share exactly one non-tokened out endpoint
        # - and one or both of the following is true
        #   1. one has a token and the other does not
        #   2. the shared endpoint is a town
        #
        # if multiple possibilities exist, pick first pair found
        def find_double_headers(routes)
          dhs = []
          routes.each do |route_a|
            next if route_a.train.distance != 2
            next if route_a.visited_stops.size != 2
            next if dhs.flatten.include?(route_a)

            partner = routes.find do |route_b|
              next false if route_b.train.distance != 2
              next false if route_b.visited_stops.size != 2
              next false if route_b == route_a
              next false if dhs.flatten.include?(route_b)

              double_header_pair?(route_a, route_b)
            end
            next unless partner

            dhs << [route_a, partner]
          end
          dhs
        end

        def double_header?(route)
          find_double_headers(route.routes).flatten.include?(route)
        end

        def find_double_header_buddies(route)
          double_headers = find_double_headers(route.routes)
          double_headers.each do |buddies|
            return buddies if buddies.include?(route)
          end
          []
        end

        def num_tile200(route, visits)
          return 0 unless @phase.name.to_i > 2
          return 0 unless @pass_thru[route.train.name]

          visits[1...-1].count { |node| node.tile.name == TILE_200 && node.tokened_by?(route.corporation) }
        end

        def build_dummy_train(route, num)
          train = @pass_thru[route.train.name]
          train.distance.each { |dist| dist[:visit] = dist[:pay] + num }
          train
        end

        def check_distance(route, visits)
          if (num = num_tile200(route, visits)).zero?
            super
          else
            super(route, visits, build_dummy_train(route, num))
          end
          return if %w[3T 4T].include?(route.train.name)

          node_hexes = {}
          visits.each do |node|
            raise GameError, 'Cannot visit multiple towns/cities in same hex' if node_hexes[node.hex]

            node_hexes[node.hex] = true
          end
          return if %w[U3 2+2].include?(route.train.name)

          raise GameError, 'Route cannot begin/end in a town' if visits.first.town? && visits.last.town?

          end_town = visits.first.town? || visits.last.town?
          end_town = false if end_town && route.train.distance == 2 && double_header?(route)
          raise GameError, 'Route cannot begin/end in a town' if end_town
        end

        def check_route_token(route, token)
          raise NoToken, 'Route must contain token' if !token && !double_header?(route)
        end

        def check_connected(route, corporation)
          # no need if distance is 2, avoids dealing with double-header route missing a token
          return if route.train.distance == 2

          super
        end

        def compute_stops(route)
          if (num = num_tile200(route, route.visited_stops)).zero?
            super
          else
            super(route, build_dummy_train(route, num))
          end
        end

        # only T trains get halt revenue
        def stop_revenue(stop, phase, train)
          return 0 if stop.tile.label.to_s == 'HALT' && train.name != '3T' && train.name != '4T'

          stop.route_revenue(phase, train)
        end

        def revenue_for(route, stops)
          buddies = find_double_header_buddies(route)
          if buddies.empty?
            stops.sum { |stop| stop_revenue(stop, route.phase, route.train) }
          else
            stops.sum do |stop|
              if buddies[-1] == route && buddies[0].stops.include?(stop)
                0
              else
                stop_revenue(stop, route.phase, route.train)
              end
            end
          end
        end

        def revenue_str(route)
          postfix = if double_header?(route)
                      ' [3 train]'
                    else
                      ''
                    end
          "#{route.hexes.map(&:name).join('-')}#{postfix}"
        end

        def price_movement_chart
          [
            ['Dividend', 'Share Price Change'],
            ['0', '1 ←'],
            ['≤ stock value/2', 'none'],
            ['> stock value/2', '1 →'],
            ['≥ 2× stock value', '2 →'],
            ['≥ 3× stock value', '3 →'],
            ['≥ 4× stock value', '4 →'],
          ]
        end

        def must_buy_train?(_entity)
          false
        end

        def check_bankrupt!(entity)
          return unless entity.corporation?
          return unless entity.share_price&.type == :close

          @log << "-- #{entity.name} is now bankrupt and will be removed from the game --"
          close_corporation(entity, quiet: true)
        end

        def hex_blocked_by_ability?(_entity, abilities, hex, _tile = nil)
          Array(abilities).any? { |ability| ability.hexes.include?(hex.id) }
        end

        def action_processed(_action); end
      end
    end
  end
end
