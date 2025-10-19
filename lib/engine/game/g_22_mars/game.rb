# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G22Mars
      class Game < Game::Base
        include_meta(G22Mars::Meta)
        include Entities
        include Map

        GAME_END_CHECK = { stock_market: :current_or, fixed_round: :current_or }.freeze

        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        BANK_CASH = 99_999
        CURRENCY_FORMAT_STR = '%sc'

        STARTING_CASH = { 2 => 450, 3 => 300, 4 => 225, 5 => 180 }.freeze

        CERT_LIMIT = { 2 => 15, 3 => 12, 4 => 9, 5 => 7 }.freeze

        CERT_LIMIT_INCLUDES_PRIVATES = false

        STOCKMARKET_COLORS = {
          par: :gray,
          multiple_buy: :red,
          close: :black,
          endgame: :green,
        }.freeze

        # TODO: Aallow swap on EMR to pay taxes in SR
        EBUY_PRES_SWAP = false
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = true

        CLOSED_CORP_TOKENS_REMOVED = false

        MUST_BUY_TRAIN = :always

        CAPITALIZATION = :incremental

        SELL_AFTER = :any_time
        SELL_BUY_ORDER = :sell_buy
        SELL_MOVEMENT = :down_share
        HOME_TOKEN_TIMING = :float

        CLOSED_CORP_RESERVATIONS_REMOVED = false

        MARKET_SHARE_LIMIT = 80

        COMPANY_CLASS = G22Mars::Company

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          multiple_buy: 'Can buy two shares in the corporation per turn',
        )

        MARKET = [
          %w[90 100 110 120 130 145 160 175 195 215 235 255 275 300e],
          %w[80 90p 100 110 120 130 145 160 175 195 215 235 255],
          %w[70 80p 90 100 110 120 130 145 160 175 195 215],
          %w[60 70p 80 90 100 110 120 130 145 160 175],
          %w[50 60p 70 80 90 100 110 120 130 145],
          %w[45 50p 55 65 75 85 95 105],
          %w[40 45 50 55 65 75],
          %w[35b 40b 45b 50b],
          %w[0c],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 3,
            tiles: [:yellow],
            operating_rounds: 2,
            status: [],
          },
          {
            name: '3',
            on: '3',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: [],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: [],
          },
          {
            name: '5',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            status: [],
          },
          {
            name: '7',
            on: '7*',
            train_limit: 3,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            status: [],
          },
          {
            name: '8',
            on: '8*',
            train_limit: 3,
            tiles: %i[yellow green brown gray black],
            operating_rounds: 2,
            status: [],
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 6,
          },
          {
            name: '3',
            distance: 3,
            price: 170,
            rusts_on: '5',
            num: 4,
          },
          {
            name: '4',
            distance: 4,
            price: 250,
            rusts_on: '7*',
            num: 3,
          },
          {
            name: '5',
            distance: 5,
            price: 340,
            rusts_on: '8*',
            num: 3,
          },
          {
            name: '7*',
            distance: 6,
            price: 440,
            num: 4,
          },
          {
            name: '8*',
            distance: 6,
            price: 560,
            num: 6,
            discount: { '5' => 160 },
          },
        ].freeze

        # Game specific constants
        LAST_OR = 11
        FIRST_REVOLT_CHECK_OR = 7
        LAST_REVOLT_CHECK_OR = 10

        def setup
          @or = 0
          @three_or_round = false
          @revolt_round = determine_revolt_round
        end

        def game_end_check_fixed_round?
          @or == LAST_OR
        end

        def setup_preround
          revolts, permits = @companies.partition(&:revolt?)
          sorted_permits = permits.sort_by { rand }
          sorted_revolts = revolts.sort_by { rand }

          @companies = sorted_permits.take(@players.size)
          assigned_companies = sorted_permits.drop(@players.size) + sorted_revolts

          assigned_companies.zip(@corporations).each do |company, corporation|
            if corporation
              company.owner = corporation
              corporation.companies << company
              @log << "#{company.name} is assigned to #{corporation.name}"
            else
              company.close!
              @log << "#{company.name} is discarded"
            end
          end
        end

        def unowned_purchasable_companies
          @companies
        end

        def init_round
          G22Mars::Round::PermitPurchase.new(self, [G22Mars::Step::SelectOrDiscard])
        end

        def new_operating_round(round_num = 1)
          @or += 1

          if @or == 9
            @operating_rounds = 3
            @three_or_round = true
          end

          round = super

          check_revolt!

          round
        end

        def or_round_finished
          # In case we get phase change during the last OR set we ensure we have 3 ORs
          @operating_rounds = 3 if @three_or_round
        end

        def revolt_happened?
          @revolt_happened
        end

        def determine_revolt_round
          (FIRST_REVOLT_CHECK_OR..LAST_REVOLT_CHECK_OR).each do |round|
            probability = LAST_REVOLT_CHECK_OR - round + 1

            return round if (rand % probability).zero?
          end
        end

        def check_revolt!
          return if @or < FIRST_REVOLT_CHECK_OR || revolt_happened?

          if @or == @revolt_round
            revolt!
          else
            @log << 'Revolt! does not happen'
          end
        end

        def revolt!
          @log << '-- Revolt!'
          @log << '-- All permits were discarded. You can now use abilities of Revolt! cards.'
          @log << '-- All Convict bases are now neutral and cities with them generate no revenue.'

          @revolt_happened = true

          @companies.each do |company|
            company.close! unless abilities(company, :close, on_phase: 'never')
          end
        end

        def ipo_name(_entity = nil)
          'Treasury'
        end

        def timeline
          [
            'OR 7: Revolt! happens with 25% chance ',
            'OR 8: Revolt! happens with 33% chance if not happened yet',
            'OR 9: Revolt! happens with 50% chance if not happened yet',
            'OR 10: Revolt! happens if not happened yet',
            'Game ends after OR 11',
          ].freeze
        end

        def show_progress_bar?
          true
        end

        def progress_information
          [
            { type: :PRE },
            { type: :SR, name: '1' },
            { type: :OR, name: '1' },
            { type: :OR, name: '2' },
            { type: :SR, name: '2' },
            { type: :OR, name: '3' },
            { type: :OR, name: '4' },
            { type: :SR, name: '3' },
            { type: :OR, name: '5' },
            { type: :OR, name: '6' },
            { type: :SR, name: '4' },
            { type: :OR, name: '7', value: draw_revolt_marker(7) },
            { type: :OR, name: '8', value: draw_revolt_marker(8) },
            { type: :SR, name: '5' },
            { type: :OR, name: '9', value: draw_revolt_marker(9) },
            { type: :OR, name: '10', value: draw_revolt_marker(10) },
            { type: :OR, name: '11' },
            { type: :End },
          ]
        end

        def draw_revolt_marker(or_number)
          if @revolt_happened
            return '✔' if or_number == @revolt_round

            or_number < @revolt_round ? '✘' : '—'
          else
            or_number == LAST_REVOLT_CHECK_OR ? '✔' : '✘/✔'
          end
        end

        def price_movement_chart
          [
            ['Action', 'Share Price Change'],
            ['Dividend 0 or withheld', '1 ←'],
            ['Dividend < 2x share price ', '1 →'],
            ['Dividend ≥ 2x share price', '2 →'],
            ['Each share sold', '1 ↓'],
            ['Fully owned at the end of SR', '1 ↑'],
          ]
        end

        def company_header(company)
          company.revolt? ? 'REVOLT!' : 'PERMIT'
        end

        def round_description(name, round_number = nil)
          return 'Permit Purchase Round' if name == 'PermitPurchase'

          super
        end
      end
    end
  end
end
