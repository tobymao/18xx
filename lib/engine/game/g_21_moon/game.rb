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

        def setup
          # pick one corp to wait until SR3
          #
        end

        #def stock_round
        #  Engine::Round::Stock.new(self, [
        #    Engine::Step::DiscardTrain,
        #    G21Moon::Step::BuySellParShares,
        #  ])
        #end

        #def operating_round(round_num)
        #  Engine::Round::Operating.new(self, [
        #    G21Moon::Step::Bankrupt,
        #    Engine::Step::Track,
        #    Engine::Step::Token,
        #    G21Moon::Step::Route,
        #    G21Moon::Step::Dividend,
        #    Engine::Step::DiscardTrain,
        #    G21Moon::Step::BuyTrain,
        #  ], round_num: round_num)
        #end

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

        def ipo_name(corp = nil)
          'Treasury'
        end

        #def redeemable_shares(entity)
        #  return [] unless entity.corporation? && entity.type != :minor

        #  bundles_for_corporation(share_pool, entity)
        #    .reject { |bundle| entity.cash < bundle.price }
        #end

        #def issuable_shares(entity)
        #  return [] unless entity.corporation? && entity.type != :minor

        #  treasury = bundles_for_corporation(entity, entity)
        #  ipo = bundles_for_corporation(@bank, entity)
        #  ipo.each { |b| b.share_price = entity.original_par_price.price }
        #  (treasury + ipo).reject do |bundle|
        #    (bundle.num_shares + entity.num_market_shares) * 10 > self.class::MARKET_SHARE_LIMIT
        #  end
        #end
      end
    end
  end
end
