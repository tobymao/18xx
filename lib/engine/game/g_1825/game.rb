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
             5
             10
             16
             24
             34
             42
             49
             55
             61
             67
             71
             76
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
             340],
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
                    available_on: '5',
                  },
                  {
                    name: 'U3',
                    distance: 3,
                    price: 410,
                    num: 2,
                    available_on: '5',
                  },
                  { name: '7', distance: 7, price: 720, num: 2 }].freeze

        SELL_MOVEMENT = :down_per_10

        HOME_TOKEN_TIMING = :operating_round

        BANK_CASH = 7_000

        CERT_LIMIT = { 2 => 17, 3 => 15 }.freeze

        STARTING_CASH = { 2 => 750, 3 => 750 }.freeze

        def init_optional_rules(optional_rules)
          optional_rules = (optional_rules || []).map(&:to_sym)
          optional_rules << :unit_1 if optional_rules.empty?

          # sanity check player count and illegal combination of options
          @units = {}
          3.times.each do |i|
            unit = i + 1
            @units[unit] = true if optional_rules.include?("unit_#{unit}".to_sym)
          end

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
           { 3 => 840, 4 => 630, 5 => 504, 6 => 420, 7 => 360, 8 => 315, 9 => 280}
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


        def setup
          @minors.each do |minor|
            hex = hex_by_id(minor.coordinates)
            hex.tile.add_reservation!(minor, minor.city)
          end
        end

        def operating_round(round_num)
          Round::Operating.new(self, [
            Step::Bankrupt,
            Step::Exchange,
            Step::BuyCompany,
            Step::Track,
            Step::Token,
            Step::Route,
            Step::Dividend,
            Step::BuyTrain,
            [Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end
      end
    end
  end
end
