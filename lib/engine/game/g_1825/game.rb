# frozen_string_literal: true

# TODO: list for 1825.
# (working on unit 3 to start)
# map - done
# map labels - done
# tileset - done
# weird promotion rules
# trains - done
# phases
# companies + minors - done
# privates - done
# market - done
# minor floating rules (train value)
# share price movemennt
#
# PHASE 2.
# Unit 2, with options for choosing which units you play with.
#
# PHASE 3
# Unit 1 + regional kits.

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1825
      class Game < Game::Base
        include_meta(G1825::Meta)
        include Entities
        include Map

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

        CURRENCY_FORMAT_STR = '£%d'

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        MARKET = [
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
             71
             76p
             82
             90
             100
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

        PHASES = [
          {
            name: '1',
            on: '2',
            train_limit: { minor: 4, major: 4 },
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '2',
            on: '3',
            train_limit: { minor: 4, major: 4 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '5',
            train_limit: { minor: 3, major: 3 },
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
        ].freeze

        # Unit 3 train set.
        TRAINS = [{ name: '2', distance: 2, price: 180, rusts_on: '5', num: 5 },
                  { name: '3', distance: 3, price: 300, num: 3 },
                  { name: '4', distance: 4, price: 430, num: 1 },
                  { name: '5', distance: 5, price: 550, num: 2 },
                  {
                    name: '3T',
                    distance: 3,
                    price: 370,
                    num: 2,
                    available_on: '3',
                  },
                  {
                    name: 'U3',
                    distance: 3,
                    price: 410,
                    num: 2,
                    available_on: '3',
                  },
                  { name: '7', distance: 7, price: 720, num: 2 }].freeze

        MINOR_INFO = {
          'GNoS' => { min_par: 55, train: '5' },
          'HR' => { min_par: 42, train: 'U3' },
          'M&C' => { min_par: 42, train: '3T' },
          'CAM' => { min_par: 42, train: 'U3' },
          'FR' => { min_par: 55, train: '5' },
          'HR' => { min_par: 42, train: 'U3' },
          'LT&S' => { min_par: 61, train: '2+2' },
          'M&GN' => { min_par: 49, train: '4T' },
          'NSR' => { min_par: 42, train: '3T' },
          'S&DR' => { min_par: 55, train: '5' },
          'TV' => { min_par: 49, train: '4T' },
        }.freeze

        SELL_MOVEMENT = :down_per_10

        HOME_TOKEN_TIMING = :operating_round

        BANK_CASH = 7_000

        CERT_LIMIT = { 2 => 17, 3 => 15 }.freeze

        def init_optional_rules(optional_rules)
          optional_rules = (optional_rules || []).map(&:to_sym)
          optional_rules << :unit_1 if optional_rules.empty?

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

          @units[1] = true if optional_rules.include?("unit_1".to_sym)
          @units[1] = true if optional_rules.include?("unit_12".to_sym)
          @units[1] = true if optional_rules.include?("unit_123".to_sym)

          @units[2] = true if optional_rules.include?("unit_2".to_sym)
          @units[2] = true if optional_rules.include?("unit_12".to_sym)
          @units[2] = true if optional_rules.include?("unit_23".to_sym)
          @units[2] = true if optional_rules.include?("unit_123".to_sym)

          @units[3] = true if optional_rules.include?("unit_3".to_sym)
          @units[3] = true if optional_rules.include?("unit_23".to_sym)
          @units[3] = true if optional_rules.include?("unit_123".to_sym)

          if @units[1] && !@units[2] && @units[3]
            raise GameError, 'Cannot combine Units 1 and 3 without Unit 2'
          end

          # FIXME: update for regional kits when added
          p_range = case @units.keys.sort.map(&:to_s).join
          when '1'
            [2, 5]
          when '2'
            [2, 4]
          when '3'
            [2]
          when '12'
            [3,7]
          when '23'
            [3,5]
          else # all units
            [4,8]
          end
          unless p_range.first <= @players.size && p_range.last >= @players.size && 
            ok_range = p_range.map(&:to_s).join('-')
            raise GameError, "Selected options require a player count of #{ok_range}"
          end

          optional_rules
        end

        def bank_by_options
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
           { 2 => 1200, 3 => 830, 4 => 630, 5 => 504}
          when '2'
           { 2 => 1200, 3 => 800, 4 => 600}
          when '3'
           { 2 => 750 }
          when '12'
           { 3 => 840, 4 => 630, 5 => 504, 6 => 420, 7 => 360}
          when '23'
           { 3 => 840, 4 => 630, 5 => 504}
          else # all units
           { 4 => 630, 5 => 504, 6 => 420, 7 => 360, 8 => 315, 9 => 280}
          end
        end

        def certs_by_options
          case @units.keys.sort.map(&:to_s).join
          when '1'
           { 2 => 24, 3 => 16, 4 => 12, 5 => 10}
          when '2'
           { 2 => 24, 3 => 16, 4 => 12}
          when '3'
           { 2 => 17 }
          when '12'
           { 3 => 31, 4 => 23, 5 => 19, 6 => 16, 7 => 14}
          when '23'
           { 3 => 29, 4 => 23, 5 => 18}
          else # all units
           { 4 => 33, 5 => 28, 6 => 23, 7 => 19, 8 => 17, 9 => 15}
          end
        end

        def init_bank
          Bank.new(bank_by_options, log: @log)
        end

        def init_starting_cash
          cash = cash_by_options[players.size]
          players.each do |player|
            bank.spend(cash, player)
          end
        end

        def init_cert_limit
          cert_limit = certs_by_options[players.size]
        end

        def setup
          @minors.each do |minor|
            hex = hex_by_id(minor.coordinates)
            hex.tile.add_reservation!(minor, minor.city)
          end
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Step::Track,
            Step::Token,
            Step::Route,
            Step::Dividend,
            Step::BuyTrain,
          ], round_num: round_num)
        end
      end
    end
  end
end
