# frozen_string_literal: true

require_relative '../base'
require_relative 'meta'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G21Moon
      class Game < Game::Base
        include_meta(G21Moon::Meta)
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

        CURRENCY_FORMAT_STR = '%dc'
        BANK_CASH = 12_000
        CERT_LIMIT = { 3 => 15, 4 => 12, 5 => 10 }.freeze
        STARTING_CASH = { 3 => 540, 4 => 410, 5 => 340 }.freeze
        CAPITALIZATION = :incremental
        MUST_SELL_IN_BLOCKS = false
        SELL_MOVEMENT = :down_block
        SOLD_OUT_INCREASE = true
        POOL_SHARE_DROP = :one # needs custom code

        MARKET = [
          ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '330', '360', '395', '430'],
          ['', '', '100', '110', '120', '130', '140', '150', '160', '175', '195', '215', '240', '265', '295', '325', '360',
           '395'],
          %w[70 80 90p 100 110 120 130 140 150 160 175 190 215 235 260 285 315 345],
          %w[60 70 80p 90 100 110 120 130 140 150 160 175 190 200 220 250 275 300],
          %w[50 60 70p 80 90 100 110 120 130 140 150 160 175 190],
          %w[40 50 60p 70 80 90 100 110 120 130 140 150],
          %w[0c 40 50 60 70 80 90 100 110 120],
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
            train_limit: { BC: 2, SP: 2 },
            tiles: %i[yellow],
            operating_rounds: 2,
          },
          {
            name: '3',
            on: '3',
            train_limit: { BC: 2, SP: 2 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: { BC: 2, SP: 2 },
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: { BC: 2, SP: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '6',
            on: '6',
            train_limit: { BC: 2, SP: 2 },
            tiles: %i[yellow green brown],
            operating_rounds: 2,
          },
          {
            name: '10',
            on: '10',
            train_limit: { BC: 2, SP: 2 },
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 120,
            rusts_on: '5',
            num: 5,
          },
          {
            name: '3',
            distance: 3,
            price: 150,
            rusts_on: '6',
            num: 4,
          },
          {
            name: '4',
            distance: 4,
            price: 240,
            rusts_on: '10',
            num: 3,
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 2,
          },
          {
            name: '6',
            distance: 6,
            price: 540,
            num: 2,
          },
          {
            name: '10',
            distance: 10,
            price: 730,
            num: 14,
          },
        ].freeze

        HOME_TOKEN_TIMING = :start
        MUST_BUY_TRAIN = :always
        SELL_MOVEMENT = :left_share_pres
        SELL_BUY_ORDER = :sell_buy
        GAME_END_CHECK = { stock_market: :current_or, bankrupt: :immediate, bank: :full_or }.freeze
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one
        LIMIT_TOKENS_AFTER_MERGER = 999
        SOLD_OUT_INCREASE = false

        # Game will end after 5 sets of ORs - checked in end_now? below
        GAME_END_CHECK = { custom: :current_or }.freeze

        GAME_END_REASONS_TEXT = Base::GAME_END_REASONS_TEXT.merge(
          custom: 'Fixed number of ORs'
        )

        # Two lays or one upgrade
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: :not_if_upgraded, upgrade: false },
        ].freeze

        LAST_OR = 11
        SP_HEX = 'E9'

        def reservation_corporations
          corporations + minors
        end

        def setup
          # adjust parameters for majors to allow both IPO and treasury stock
          # place BC and SP tokens
          #
          @corporations.each do |corp|
            corp.ipo_owner = @bank
            corp.share_holders.keys.each do |sh|
              next if sh == @bank

              sh.shares_by_corporation[corp].dup.each { |share| transfer_share(share, @bank) }
            end
            place_home_token(corp)
            place_sp_token(corp)
          end

          # pick one corp to wait until SR3
          #

          @or = 0
          @three_or_round = false
        end

        def transfer_share(share, new_owner)
          corp = share.corporation
          corp.share_holders[share.owner] -= share.percent
          corp.share_holders[new_owner] += share.percent
          share.owner.shares_by_corporation[corp].delete(share)
          new_owner.shares_by_corporation[corp] << share
          share.owner = new_owner
        end

        def place_sp_token(corporation)
          sp_token = corporation.tokens.first.dup

          sp_tile = hex_by_id(self.class::SP_HEX).tile
          sp_tile.cities.first.place_token(corporation, sp_token)
          @log << "#{corporation.name} places a token on #{self.class::SP_HEX}"
        end

        def stock_round
          Engine::Round::Stock.new(self, [
            G21Moon::Step::BuySellParShares,
          ])
        end

        def new_operating_round(round_num = 1)
          @or += 1

          if @or == 9
            @operating_rounds = 3
            @three_or_round = true
          end

          super
        end

        def or_round_finished
          # In case we get phase change during the last OR set we ensure we have 3 ORs
          @operating_rounds = 3 if @three_or_round
        end

        # FIXME: add CR
        def round_description(name, _round_num = nil)
          case name
          when 'Stock'
            super
          when 'Draft'
            name
          else # 'Operating'
            message += " - Game end after OR #{LAST_OR}" if @or > 8
            "#{name} Round #{@or} (of #{LAST_OR})#{message}"
          end
        end

        # def operating_round(round_num)
        #  Engine::Round::Operating.new(self, [
        #    G21Moon::Step::Bankrupt,
        #    Engine::Step::Track,
        #    Engine::Step::Token,
        #    G21Moon::Step::Route,
        #    G21Moon::Step::Dividend,
        #    Engine::Step::DiscardTrain,
        #    G21Moon::Step::BuyTrain,
        #  ], round_num: round_num)
        # end

        # FIXME: add CR
        def next_round!
          @round =
            case @round
            when Round::Stock
              @operating_rounds = @phase.operating_rounds
              reorder_players
              new_operating_round
            when Round::Operating
              if @round.round_num < @operating_rounds
                or_round_finished
                new_operating_round(@round.round_num + 1)
              else
                @turn += 1
                or_round_finished
                or_set_finished
                new_stock_round
              end
            when init_round.class
              init_round_finished
              reorder_players
              new_stock_round
            end
        end

        # Game will end directly after the end of OR 11
        def end_now?(_after)
          @or == LAST_OR
        end

        # ignore minors
        def operating_order
          @corporations.select(&:floated?).sort
        end

        def operated_operators
          @corporations.select(&:operated?)
        end

        def bank_sort(corporations)
          corporations.reject(&:minor?).sort_by(&:name)
        end

        def timeline
          @timeline ||= [
            'SR 3: 7th corporation becomes available',
            'OR 6: Space Port upgraded to 30c',
            'OR 7: Remaining private companies close',
            'OR 9: Space Port upgraded to 40c',
            "Game ends after OR #{LAST_OR}",
          ].freeze
          @timeline
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
            { type: :CR },
            { type: :SR, name: '2' },
            { type: :OR, name: '3' },
            { type: :OR, name: '4' },
            { type: :CR },
            { type: :SR, name: '3' },
            { type: :OR, name: '5' },
            { type: :OR, name: '6' },
            { type: :CR },
            { type: :SR, name: '4' },
            { type: :OR, name: '7' },
            { type: :OR, name: '8' },
            { type: :CR },
            { type: :SR, name: '5' },
            { type: :OR, name: '9' },
            { type: :OR, name: '10' },
            { type: :OR, name: '11' },
            { type: :End },
          ]
        end

        def separate_treasury?
          true
        end

        def ipo_name(_corp)
          'IPO'
        end
      end
    end
  end
end
