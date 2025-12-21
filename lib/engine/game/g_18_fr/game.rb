# frozen_string_literal: true

require_relative '../g_1817/game'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'
require_relative 'train'

module Engine
  module Game
    module G18FR
      class Game < G1817::Game
        include_meta(G18FR::Meta)
        include G18FR::Entities
        include G18FR::Map

        attr_accessor :extra_cert_limit

        CURRENCY_FORMAT_STR = '%s F'

        BANK_CASH = 99_999

        CERT_LIMIT = { 3 => 16, 4 => 12, 5 => 10, 6 => 8 }.freeze

        STARTING_CASH = { 3 => 380, 4 => 290, 5 => 220, 6 => 190 }.freeze

        NEXT_SR_PLAYER_ORDER = :first_to_pass

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one
        ALLOW_TRAIN_BUY_FROM_OTHER_PLAYERS = false

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

        FINAL_2PLUS_PRICE = 90
        FINAL_3PLUS_PRICE = 180
        FINAL_2P_PRICE = 270
        FINAL_5_PRICE = 480
        FINAL_6D_PRICE = 640

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '3P', num: 40 },
                  { name: '2+', distance: 2, price: 100, final_price: FINAL_2PLUS_PRICE, obsolete_on: '3P', num: 4 },
                  { name: '3+', distance: 3, price: 300, final_price: FINAL_3PLUS_PRICE, obsolete_on: 'G*D', num: 12 },
                  { name: '3P', distance: 3, price: 400, num: 1 },
                  { name: '2P', distance: 2, price: 300, final_price: FINAL_2P_PRICE, num: 5 },
                  { name: '5', distance: 5, price: 600, final_price: FINAL_5_PRICE, num: 6 },
                  { name: '6*D', distance: 6, price: 800, final_price: FINAL_6D_PRICE, num: 30 },
                  { name: '2P*', distance: 2, price: 200, num: 1 }].freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'two_tile_lays' => ['Two tiles', 'Corporations may lay two tiles for 20 F. One may be upgrade.'\
                                           'Can\'t upgrade the tile just laid'],
          'free_ports' => ['Free ports', 'Ports no longer count towards train length']
        ).freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          discounted_six: "6*D discounted to #{FINAL_6D_PRICE} F"
        )

        GAME_END_CHECK = { bankrupt: :immediate, discounted_six: :one_more_full_or_set }.freeze

        OR_COUNT_IN_LAST_SET = 4

        ONE_YELLOW_TILE_LAY = [{ lay: true, upgrade: false }].freeze
        TWO_TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: :not_if_upgraded, cost: 20, cannot_reuse_same_hex: true },
        ].freeze

        B_HEX_NAMES = %w[E8 H3].freeze
        YELLOW_B_TILE_NAME = 'FRBY'
        GREEN_B_TILE_NAME = 'FRBG'

        def setup
          @extra_cert_limit = Hash.new { |h, k| h[k] = 0 }
          @end_game_triggered = false
        end

        def timeline
          @timeline = [
            'At the end of each OR the next available train will be exported
            (removed, triggering phase change as if purchased). All remaining
            trains of the same type will be discounted by 10% of the base price.
            Once the price is lowest possible (see below), all remaining trains of
            the type are exported.',
            "2 #{format_currency(100)}",
            "2+ #{format_currency(100)}, #{format_currency(FINAL_2PLUS_PRICE)}",
            "3+ #{format_currency(300)}, #{format_currency(270)}, #{format_currency(240)}, "\
            "#{format_currency(210)}, #{format_currency(FINAL_3PLUS_PRICE)}",
            "3P #{format_currency(400)}",
            "2P #{format_currency(300)}, #{format_currency(FINAL_2P_PRICE)}",
            "5 #{format_currency(600)}, #{format_currency(540)}, #{format_currency(FINAL_5_PRICE)}",
            "6*D #{format_currency(800)}, #{format_currency(720)}, #{format_currency(FINAL_6D_PRICE)}",
          ]
        end

        def init_round
          # skipping the initial auction for now
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter = 1
          stock_round
        end

        def init_train_handler
          trains = game_trains.flat_map do |train|
            Array.new((train[:num] || num_trains(train))) do |index|
              G18FR::Train.new(**train, index: index)
            end
          end

          Engine::Depot.new(trains, self)
        end

        def stock_round
          close_bank_shorts
          @interest_fixed = nil

          G18FR::Round::Stock.new(self, [
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
            G18FR::Step::BuyTrain,
          ], round_num: round_num)
        end

        def next_round!
          clear_interest_paid
          @round =
            case @round
            when G18FR::Round::Stock
              reorder_players
              @log << "-- Share Redemption Round #{@turn} -- "
              G18FR::Round::ShareRedemption.new(self, [
                G18FR::Step::RedeemShares,
              ])
            when G18FR::Round::ShareRedemption
              @operating_rounds = @final_operating_rounds || @phase.operating_rounds
              new_operating_round
            when Engine::Round::Operating
              or_round_finished
              # Store the share price of each corp to determine if they can be acted upon in the AR
              @stock_prices_start_merger = @corporations.to_h { |corp| [corp, corp.share_price] }
              @log << "-- #{round_description('Merger and Conversion', @round.round_num)} --"
              G1817::Round::Merger.new(self, [
                G1817::Step::ReduceTokens,
                Engine::Step::DiscardTrain,
                G1817::Step::PostConversion,
                G1817::Step::PostConversionLoans,
                G1817::Step::Conversion,
              ], round_num: @round.round_num)
            when G1817::Round::Merger
              @log << "-- #{round_description('Acquisition', @round.round_num)} --"
              G1817::Round::Acquisition.new(self, [
                G1817::Step::ReduceTokens,
                G1817::Step::Bankrupt,
                G1817::Step::CashCrisis,
                Engine::Step::DiscardTrain,
                G1817::Step::Acquire,
              ], round_num: @round.round_num)
            when G1817::Round::Acquisition
              if @round.round_num < @operating_rounds
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_set_finished
                new_stock_round
              end
            when init_round.class
              reorder_players
              new_stock_round
            end
        end

        def loan_amount
          # needed for render_take_loan in Share Redemption Round
          @loan_value
        end

        def cert_limit(player = nil)
          if player
            # +1 cert limit for every SR with short
            @cert_limit + @extra_cert_limit[player]
          else
            @cert_limit
          end
        end

        def info_train_price(train)
          format_currency(train.price)
        end

        def or_round_finished
          return if @end_game_triggered || @depot.upcoming.empty?

          train_to_export = @depot.upcoming.first
          case train_to_export.name
          when '2'
            depot.export_all!('2')
          when @depot.upcoming[1].name
            if train_to_export.price == train_to_export.final_price
              return if train_to_export.name == '6*D'

              @depot.export_all!(train_to_export.name, silent: true)
              @log << "-- #{train_to_export.name} trains can no longer be discounted. "\
                      "All remaining  #{train_to_export.name} trains are exported --"
            else
              depot.export!
              # Discount all trains of the given type, so Info Train shows the correct price
              trains_to_discount = @depot.trains.select { |t| t.name == train_to_export.name }
              trains_to_discount.each { |t| t.new_price(t.price - (0.1 * t.base_price)) }
              @log << "-- All remaining #{train_to_export.name} trains are discounted to "\
                      "#{format_currency(@depot.upcoming.first.price)} --"
              if train_to_export.name == '6*D' && train_to_export.price == FINAL_6D_PRICE
                @end_game_triggered = true
                game_end_check
                @log << "-- Final train discount. The game will end at the end of OR #{@turn + 1}.#{OR_COUNT_IN_LAST_SET} --"
              end
            end
          else
            depot.export!
          end
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

        def game_end_check_discounted_six?
          @end_game_triggered
        end
      end
    end
  end
end
