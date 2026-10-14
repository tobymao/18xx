# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative 'tiles'
require_relative '../base'

module Engine
  module Game
    module GFrost1831
      # Data skeleton: map, entities, market, trains and phases. Rounds use the engine defaults;
      # factions, parliament, influence and the other rules follow in later PRs.
      class Game < Game::Base
        include_meta(GFrost1831::Meta)
        include Entities
        include Map
        include Tiles

        CURRENCY_FORMAT_STR = '£%s'

        BANK_CASH = 9000

        STARTING_CASH = { 2 => 1200, 3 => 800, 4 => 600, 5 => 480 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = false

        SELL_BUY_ORDER = :sell_buy

        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: :not_if_upgraded, upgrade: false },
        ].freeze

        CERT_LIMIT = {
          2 => { 8 => 31, 7 => 27, 6 => 25, 5 => 22 },
          3 => { 8 => 25, 7 => 22, 6 => 20, 5 => 18 },
          4 => { 8 => 22, 7 => 20, 6 => 18, 5 => 16 },
          5 => { 8 => 19, 7 => 17, 6 => 15, 5 => 14 },
        }.freeze

        MARKET = [
          %w[_ _B!d _B!d _B!d _B!d _B!d _B!d _B!d _B!d _B!d _B!d _B!d _B!d _],
          %w[_c!n 70y 80 90 100p 110 120 140 160 190 220 250 300K _B!l],
          %w[_c!n 60y 70 80 90p 100 110 130 150 180 210 240K],
          %w[_c!n 50y 60 70 80p 90 100 120 140 170 200K],
          %w[_c!n 40y 50 60 70p 80 90 110 130 160K],
          %w[_c!n 30y 40 50 60p 70 80 100 120K],
          %w[_c!n 20y 30 40 50 60 70 80K],
          %w[_c!n 10y 20 30 40 50 60K],
          %w[_c!n _c!n],
          %w[70r 80r 100r 120r 140r 160r 190r 220r 250r!n],
        ].freeze

        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          close: :orange,
          pays_bonus: :purple,
          pays_unique_bonus: :blue,
          repar: :gray,
        ).freeze

        MARKET_TEXT = Base::MARKET_TEXT.merge(
          par: 'Initial Offering (£60–£100)',
          close: 'Intervention Zone — corporation is eliminated',
          pays_bonus: 'Influence Zone — grants Influence',
          pays_unique_bonus: 'Influence — first to arrive',
          no_cert_limit: 'Shares do not count towards cert limit, may hold >60%',
          repar: 'Faction Values in Parliament',
        ).freeze

        PHASES = [
          {
            name: '2',
            on: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: 'D',
            on: 'D',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: 2,
            price: 80,
            rusts_on: '4',
            num: 8,
          },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 5,
          },
          {
            name: '4',
            distance: 4,
            price: 300,
            rusts_on: 'D',
            num: 4,
          },
          {
            name: '5',
            distance: 5,
            price: 530,
            num: 3,
          },
          {
            name: '6',
            distance: 6,
            price: 630,
            num: 2,
          },
          {
            name: 'D',
            distance: 999,
            price: 1100,
            num: 'unlimited',
            available_on: '6',
            discount: { '4' => 300, '5' => 300, '6' => 300, '4◆' => 300, '5◆' => 300, '6◆' => 300 },
          },
        ].freeze

        # Round definitions use engine defaults only; the custom steps follow in later PRs
        def stock_round
          Engine::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::BuyCompany,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end
      end
    end
  end
end
