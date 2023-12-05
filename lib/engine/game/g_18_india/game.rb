# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'

module Engine
  module Game
    module G18India
      class Game < Game::Base
        include_meta(G18India::Meta)
        include Map
        include Entities

        register_colors(brown: '#a05a2c',
                        purple: '#5a2ca0',
                        red: '#d1232a',
                        black: '#000',
                        white: '#ffffff'
                        )
        
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy_sell
        CURRENCY_FORMAT_STR = '$%s'
        GAME_END_CHECK = { bank: :immediate }.freeze
        MARKET_SHARE_LIMIT = 100
        SELL_MOVEMENT = :none
        BANK_CASH = 9_000
        MUST_BUY_TRAIN = :never
        POOL_SHARE_DROP = :none
        SOLD_OUT_INCREASE = false

        STOCK_PRICES = {
          'BNR' => 82,
          'BR' => 71,
        }.freeze
        
        CERT_LIMIT = { 2 => 37, 3 => 23, 4 => 18, 5 => 15 }.freeze

        STARTING_CASH = { 2 => 1100, 3 => 733, 4 => 550, 5 => 440 }.freeze

        MARKET = [
          %w[0c 
             56
             58
             61
             64p
             67p
             71p
             76p
             82p
             90p
             100p
             112p
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
             340
             360
             380
             400
             420
             440
             460],
        ].freeze

        PHASES = [
          { name: '2', train_limit: 2, tiles: %i[yellow green brown gray], operating_rounds: 2 },
          { name: '3', on: '3', train_limit: 2, tiles: %i[yellow green brown gray], operating_rounds: 2 },
          { name: '4', on: '4', train_limit: 2, tiles: %i[yellow green brown gray], operating_rounds: 2 },
          { name: '5', on: '5', train_limit: 2, tiles: %i[yellow green brown gray], operating_rounds: 2 },
        ].freeze
        
        TRAINS = [
          { name: '2', distance: 2, price: 180, num: 7 },
          { name: '3', distance: 3, price: 300, num: 6 },
          { name: '4', distance: 4, price: 450, num: 5 },
          { name: '5', distance: 999, price: 1100, num: 5 },
        ].freeze
        
        #LAYOUT = :pointy

        def operating_round(round_num)
          Engine::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            Engine::Step::HomeToken,
            Engine::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            Engine::Step::Dividend,
            Engine::Step::DiscardTrain,
            Engine::Step::BuyTrain,
            [Engine::Step::BuyCompany, { blocks: false }],
          ], round_num: round_num)
        end
        
        end
      end
    end
  end
end