# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G18Scan
      class Game < Game::Base
        include_meta(G18Scan::Meta)
        include Map
        include Entities

        GAME_END_CHECK = { bank: :full_or }.freeze

        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        BANK_CASH = 6_000

        CURRENCY_FORMAT_STR = 'K%d'

        STARTING_CASH = { 2 => 900, 3 => 600, 4 => 450 }.freeze

        CAPITALIZATION = :incremental

        SELL_AFTER = :operate

        SELL_BUY_ORDER = :sell_buy

        HOME_TOKEN_TIMING = :float

        MUST_BUY_TRAIN = :always

        CERT_LIMIT = { 2 => 18, 3 => 12, 4 => 9 }.freeze

        # Custom constants
        SJ_NAME = 'SJ'

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'close_minors' => [
            'Minors merge into SJ',
            'Minors are closed, transferring all assets to SJ. Minor owners get a 10% SJ share',
          ],
          'full_cap' => [
            'Full capitalisation',
            'Corporationss receive full capitalisation when started',
          ],
        ).freeze

        STATUS_TEXT = {
          'float_2' => [
            '20% to float',
            'An unstarted corporation needs 20% sold to start for the first time',
          ],
          'float_3' => [
            '30% to float',
            'An unstarted corporation needs 30% sold to start for the first time',
          ],
          'float_4' => [
            '40% to float',
            'An unstarted corporation needs 40% sold to start for the first time',
          ],
          'float_5' => [
            '50% to float',
            'An unstarted corporation needs 50% sold to start for the first time',
          ],
          'incremental_cap' => [
            'Incremental capitalization',
            'Corporations receive capitalisation for sold shares when started',
          ],
          'full_cap' => [
            'Full capitalization',
            'Corporations receive full capitalisation when started',
          ],
          'sj_can_float' => [
            'SJ can float',
            'SJ can float if 50% of its shares are sold, receiving K700 from the bank',
          ],
        }.freeze

        MARKET = [
          %w[82 90 100 110 122 135 150 165 180 200 220 245 270 300 330 360 400],
          %w[75 82 90 100 110 122 135 150 165 180 200 220 245 270],
          %w[70 75 82 90 100p 110 122 135 150 165 180],
          %w[65 70 75 82p 90p 100 110 122],
          %w[60 65 70p 75p 82 90],
          %w[50 60 65 70 75],
          %w[40 50 60 65],
        ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            status: %w[incremental_cap float_2],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %w[yellow green],
            operating_rounds: 2,
            status: %w[float_3 incremental_cap],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %w[yellow green],
            operating_rounds: 2,
            status: %w[float_4 incremental_cap],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %w[yellow green brown],
            operating_rounds: 2,
            events: [
              { 'type' => 'close_minors' },
              { 'type' => 'close_companies' },
              { 'type' => 'full_cap' },
            ],
            status: %w[float_5 full_cap sj_can_float],
          },
          {
            name: '5E',
            on: '5E',
            train_limit: 2,
            tiles: %w[yellow green brown],
            operating_rounds: 2,
            status: %w[float_5 full_cap],
          },
          {
            name: '4D',
            on: '4D',
            train_limit: 2,
            tiles: %w[yellow green brown],
            operating_rounds: 2,
            status: %w[float_5 full_cap],
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 100,
            rusts_on: '4',
            num: 6,
            variants: [
              {
                name: '1+1',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 1, 'visit' => 1 },
                  { 'nodes' => ['town'], 'pay' => 1, 'visit' => 1 },
                ],
                price: 80,
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            price: 200,
            rusts_on: '5',
            num: 4,
            variants: [
              {
                name: '2+2',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 2, 'visit' => 2 },
                  { 'nodes' => ['town'], 'pay' => 2, 'visit' => 2 },
                ],
                price: 180,
              },
            ],
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: '4D',
            num: 3,
            variants: [
              {
                name: '3+3',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 3, 'visit' => 3 },
                  { 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                ],
                price: 80,
              },
            ],
          },
          {
            name: '5',
            distance: 5,
            price: 500,
            num: 2,
            variants: [
              {
                name: '4+4',
                distance: [
                  { 'nodes' => ['city'], 'pay' => 4, 'visit' => 4 },
                  { 'nodes' => ['town'], 'pay' => 4, 'visit' => 4 },
                ],
                price: 480,
              },
            ],
          },
          {
            name: '5E',
            distance: [
              { 'nodes' => ['city'], 'pay' => 5, 'visit' => 5 },
              { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
            ],
            price: 600,
            num: 2,
          },
          {
            name: '4D',
            distance: [
              { 'nodes' => ['city'], 'pay' => 4, 'visit' => 4, 'multiplier' => 2 },
              { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 },
            ],
            price: 800,
            num: 2,
          },
        ].freeze

        def setup
          # SJ cannot float until phase 5
          sj.floatable = false

          # Minors come with a trade-in share of SJ
          minors.each do |minor|
            share = sj_share_by_minor(minor.name)
            share.buyable = false
            share.counts_for_limit = false
          end
        end

        def new_auction_round
          Round::Auction.new(self, [
            Engine::Step::CompanyPendingPar,
            G18Scan::Step::WaterfallAuction,
          ])
        end

        def stock_round
          Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G18Scan::Step::BuySellParShares,
          ])
        end

        def train_limit(entity)
          super + Array(abilities(entity, :train_limit)).sum(&:increase)
        end

        def sj
          @sj ||= corporation_by_id('SJ')
        end

        def sj_share_by_minor(name)
          return sj.shares[6] if name == '1'
          return sj.shares[7] if name == '2'
          return sj.shares[8] if name == '3'
        end
      end
    end
  end
end
