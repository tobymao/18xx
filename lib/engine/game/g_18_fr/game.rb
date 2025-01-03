# frozen_string_literal: true

require_relative '../g_1817/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18FR
      class Game < G1817::Game
        include_meta(G18FR::Meta)
        include G18FR::Entities
        include G18FR::Map

        CURRENCY_FORMAT_STR = '%s F'

        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 16, 4 => 12, 5 => 10, 6 => 8 }.freeze

        STARTING_CASH = { 3 => 380, 4 => 290, 5 => 220, 6 => 190 }.freeze

        NEXT_SR_PLAYER_ORDER = :first_to_pass

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[0l
             0a
             0a
             0a
             40
             45p
             50p
             55s
             60p
             65p
             70s
             80p
             90p
             100p
             110p
             120s
             135p
             150p
             165p
             180p
             200p
             220
             245
             270
             300
             330
             360
             400
             440
             490
             540
             600
             660
             720
             780
             840
             900],
           ].freeze

        PHASES = [
          {
            name: 'Yellow',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [2],
          },
          {
            name: 'Yellow+',
            on: '2+',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [2, 5],
          },
          {
            name: 'Green',
            on: '3+',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [2, 5],
            status: ['two_tile_lays'],
          },
          {
            name: 'Blue',
            on: '3P',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [2, 5],
            status: %w[two_tile_lays free_ports],
          },
          {
            name: 'Brown',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [2, 5],
            status: %w[two_tile_lays free_ports],
          },
          {
            name: 'Gray',
            on: '6*D',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [2, 5],
            status: %w[two_tile_lays free_ports],
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '3P', num: 40 },
                  { name: '2+', distance: 2, price: 100, obsolete_on: '3P', num: 4 },
                  { name: '3+', distance: 3, price: 300, obsolete_on: 'G*D', num: 12 },
                  { name: '3P', distance: 3, price: 400, num: 1 },
                  { name: '2P', distance: 2, price: 300, num: 5 },
                  { name: '5', distance: 5, price: 600, num: 6 },
                  { name: '6*D', distance: 6, price: 800, num: 30 },
                  { name: '2P*', distance: 2, price: 200, num: 1 }].freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'two_tile_lays' => ['Two tiles', 'Corporations may lay two tiles for 20 F. One may be upgrade.'\
                                           'Can\'t upgrade the tile just laid'],
          'free_ports' => ['Free ports', 'Ports no longer count towards train length']
        ).freeze

        ONE_YELLOW_TILE_LAY = [{ lay: true, upgrade: false }].freeze
        TWO_TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        B_HEX_NAMES = %w[E8 H3].freeze
        YELLOW_B_TILE_NAME = 'FRBY'
        GREEN_B_TILE_NAME = 'FRBG'

        def init_round
          # skipping the initial auction for now
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter = 1
          stock_round
        end

        def stock_round
          close_bank_shorts
          @interest_fixed = nil

          G1817::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::HomeToken,
            G18FR::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          @interest_fixed = interest_rate

          G1817::Round::Operating.new(self, [
            G1817::Step::Bankrupt,
            G1817::Step::CashCrisis,
            G1817::Step::Loan,
            G1817::Step::SpecialTrack,
            G1817::Step::Assign,
            G18FR::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1817::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1817::Step::BuyTrain,
          ], round_num: round_num)
        end

        def tile_lays(_entity)
          @phase.status.include?('two_tile_lays') ? TWO_TILE_LAYS : ONE_YELLOW_TILE_LAY
        end

        def upgrades_to?(from, to, _special = false, selected_company: nil)
          # This is needed because yellow B tile adds a town (and green tile removes it)
          return YELLOW_B_TILE_NAME == to.name if B_HEX_NAMES.include?(from.hex&.name) && from.color == :white
          return GREEN_B_TILE_NAME == to.name if from.name == YELLOW_B_TILE_NAME && from.color == :yellow

          super
        end
      end
    end
  end
end
