# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'

module Engine
  module Game
    module G18OE
      class Game < Game::Base
        include_meta(G18OE::Meta)
        attr_accessor :minor_regional_order, :minor_available_regions, :minor_floated_regions, :regional_corps_floated

        MARKET = [
          ['', '110', '120C', '135', '150', '165', '180', '200', '225', '250', '280', '310', '350', '390', '440', '490', '550'],
          %w[90p 100 110C 120 135 150 165 180 200 225 250 280 310 350 390 440 490],
          %w[80p 90 100C 110 120 135 150 165 180 200 225 250 280 310],
          %w[75p 80 90C 100 110 120 135 150 165 180 200],
          %w[70p 75 80C 90 100 110 120 135 150],
          %w[65p 70 75C 80 90 100 110],
          %w[60p 65 70 75 80],
          %w[50 60 65 70],
        ].freeze
        CERT_LIMIT = { 3 => 48, 4 => 36, 5 => 29, 6 => 24, 7 => 20 }.freeze
        STARTING_CASH = { 3 => 1735, 4 => 1300, 5 => 1040, 6 => 870, 7 => 745 }.freeze
        BANK_CASH = 54_000
        CAPITALIZATION = :incremental
        SELL_BUY_ORDER = :sell_buy
        MUST_SELL_IN_BLOCKS = false
        HOME_TOKEN_TIMING = :float
        TILE_UPGRADES_MUST_USE_MAX_EXITS = [:cities].freeze

        STOCKMARKET_COLORS = {
          par: :blue,
          convert_range: :red,
        }.freeze

        MARKET_TEXT = {
          par: 'Regional par values',
          convert_range: 'Major par values',
        }.freeze

        PHASES = [
          {
            name: '2',
            train_limit: 3,
            tiles: [:yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2+2',
            distance: [{ 'nodes' => ['town'], 'pay' => 2, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
            price: 100,
            num: 5,
          },
          {
            name: '3',
            distance: [{ 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
                       { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
            price: 200,
            variants: [{
              name: '3+3',
              distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 99 },
                         { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
              price: 225,
            }],
            num: 4,
          },
        ].freeze

        CORPORATIONS_TRACK_RIGHTS = {
          'LNWR' => 'UK',
          'GWR' => 'UK',
          'GSWR' => 'UK',
          'PLM' => 'FR',
          'MIDI' => 'FR',
          'OU' => 'FR',
          'BEL' => 'FR',
        }.freeze

        NATIONAL_REGION_HEXES = {
          'UK' => %w[D25 E24 E26 E28 F23 F25 F27 F29 G16 G18 G20 G24 G26 G28 H15 H17 H19 H21 H25 H27 H29 I14 I16 I18 I20 I26 I28
                     J13 J15 J17 J19 J23 J25 J27 J29 K22 K24 K26 K28 K30 L23 L25 L27 L29 L31 M22 M24 M26 M28 M30],
          'FR' => %w[N31 N33 N35 N37 O24 O28 O30 O32 O34 O36 O38 P19 P21 P23 P25 P27 P29 P31 P33 P35 P37 Q20 Q22 Q24 Q26 Q28 Q30
                     Q32 Q34 Q36 Q38 R23 R25 R27 R29 R31 R33 R35 R37 R39 S24 S26 S28 S30 S32 S34 S36 S38 T23 T25 T27 T29 T31 T33
                     T35 T37 U22 U24 U26 U28 U30 U32 U34 U36 U38 V21 V23 V25 V27 V29 V31 V33 V35 V37 W22 W24 W26 W28 W30 W32 W34
                     W36 W38 X25 X27 X29 X33 X35 X37 Y28 Z41], # plus Alger
        }.freeze

        TRACK_RIGHTS_COST = {
          'UK' => 40,
          'FR' => 20,
        }.freeze

        MAX_FLOATED_REGIONALS = 18

        # still need green+ OE specific track tiles
        TILES = {
          '3' => 14,
          '4' => 25,
          '5' => 25,
          '6' => 15,
          '7' => 14,
          '8' => 99,
          '9' => 99,
          '12' => 10,
          '13' => 8,
          '57' => 19,
          '58' => 25,
          '80' => 5,
          '81' => 5,
          '82' => 20,
          '83' => 20,
          '141' => 15,
          '142' => 15,
          '143' => 5,
          '144' => 5,
          '145' => 13,
          '146' => 21,
          '147' => 13,
          '201' => 9,
          '202' => 18,
          '205' => 17,
          '206' => 17,
          '207' => 12,
          '208' => 9,
          '544' => 8,
          '545' => 8,
          '546' => 7,
          '621' => 12,
          '622' => 9,
          'OE1' =>
            {
              'count' => 4,
              'color' => 'yellow',
              'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:3',
            },
          'OE2' =>
            {
              'count' => 6,
              'color' => 'yellow',
              'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:2',
            },
          'OE3' =>
            {
              'count' => 2,
              'color' => 'yellow',
              'code' => 'town=revenue:10;town=revenue:10;path=a:0,b:_0;path=a:_0,b:_1;path=a:_1,b:1',
            },
          'OE4' =>
            {
              'count' => 5,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:2,b:_1;path=a:4,b:_2;label=ABP',
            },
          'OE5' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:_0,b:1;path=a:5,b:_1;path=a:_1,b:3;label=C',
            },
          'OE6' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:5,b:_0;path=a:2,b:_1;path=a:4,b:_1;label=L',
            },
          'OE7' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;path=a:1,b:_0;path=a:4,b:_1;label=N',
            },
          'OE8' =>
            {
              'count' => 1,
              'color' => 'yellow',
              'code' => 'city=revenue:30;city=revenue:30;path=a:0,b:_0;path=a:5,b:_1;label=S',
            },
        }.freeze

        def setup
          super
          @minor_regional_order = []
          @minor_available_regions = %w[UK UK FR FR] # this should be set per variant, big game will need extra logic
          @minor_floated_regions = {}
          @regional_corps_floated = 0
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def operating_order
          @minor_regional_order + (@corporations.select(&:floated?) - @minor_regional_order).sort
        end

        def hex_within_national_region?(entity, hex)
          NATIONAL_REGION_HEXES[CORPORATIONS_TRACK_RIGHTS[entity.id] || @minor_floated_regions[entity.id]].include?(hex.name)
        end

        def home_token_locations(corporation)
          # if minor, choose non-metropolis hex
          # if regional, starts on reserved hex

          available_regions = NATIONAL_REGION_HEXES.select { |key, _value| @minor_available_regions.include?(key) }
          region_hexes = available_regions.values.flatten

          @hexes
            .select { |hex| region_hexes.include?(hex.name.to_s) }
            .select { |hex| hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) } }
            .reject { |hex| metropolis_hex?(hex) }
        end

        def metropolis_hex?(hex)
          %w[A56 B41 C74 F87 K26 M28 M50 Q30 R55 Y14 AA82 BB51].include?(hex.name.to_s)
        end

        def metropolis_tile?(tile)
          %w[OE4 OE5 OE6 OE7 OE8 OE12 OE13 OE14 OE15 OE16 OE17
             OE18 OE26 OE27 OE28 OE29 OE30 OE37 OE38 OE39 OE40 OE41].include?(tile.name.to_s)
        end

        def upgrades_to_correct_label?(from, to)
          return true if from.label == to.label
          return false if from.label && !to.label

          case from.hex.name
          when 'K26', 'Y14', 'R55'
            to.label.to_s.include?('A')
          when 'M50'
            to.label.to_s.include?('B')
          when 'AA82'
            to.label.to_s.include?('C')
          when 'Q30'
            to.label.to_s.include?('P')
          when 'C74'
            to.label.to_s.include?('S')
          end
        end

        def company_becomes_minor?(company)
          corp = @corporations.find { |c| c.name == company.sym }
          return unless corp

          corp.type == :minor
        end

        def form_button_text(_entity)
          'Float'
        end

        def after_par(corporation)
          super
          # Spend the cost of the regionals track rights zone
          region = NATIONAL_REGION_HEXES.select { |_key, value| value.include?(corporation.coordinates) }.keys.first
          corporation.spend(TRACK_RIGHTS_COST[region], @bank)
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18OE::Step::HomeToken,
            G18OE::Step::BuySellParShares,
          ])
        end

        def new_auction_round
          Round::Auction.new(self, [
            G18OE::Step::WaterfallAuction,
          ])
        end

        def operating_round(round_num)
          Round::G18OE::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G18OE::Step::Track,
            G18OE::Step::Token,
            Engine::Step::Route,
            G18OE::Step::Dividend,
            Engine::Step::BuyTrain,
            Engine::Step::IssueShares,
          ], round_num: round_num)
        end
      end
    end
  end
end
