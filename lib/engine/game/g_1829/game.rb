# frozen_string_literal: true

require_relative 'meta'
require_relative '../base'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1829
      class Game < Game::Base
        include_meta(G1829::Meta)
        include G1829::Entities
        include G1829::Map
        register_colors(red: '#d1232a',
                        orange: '#f58121',
                        black: '#110a0c',
                        blue: '#025aaa',
                        lightBlue: '#8dd7f6',
                        yellow: '#ffe600',
                        green: '#32763f',
                        brightGreen: '#6ec037')
        TRACK_RESTRICTION = :permissive
        SELL_BUY_ORDER = :sell_buy_sell
        CURRENCY_FORMAT_STR = '$%dP'
        GAME_END_CHECK = { bank: :immediate }.freeze
        MARKET_SHARE_LIMIT = 100

        BANK_CASH = 20_000

        CERT_LIMIT = { 3 => 18, 4 => 18, 5 => 17, 6 => 14, 7 => 12, 8 => 10, 9 => 9 }.freeze

        STARTING_CASH = { 3 => 840, 4 => 630, 5 => 1504, 6 => 420, 7 => 360, 8 => 315, 9 => 280 }.freeze

        LOCATION_NAMES = {
        }.freeze

        MARKET = [
          %w[0c 10y
             20y
             29y
             38
             47
             53
             56p
             58p
             61p
             64p
             67p
             71p
             76p
             82p
             90p
             100p
             112
             126
             142
             160
             180
             200
             225
             250
             275
             300
             320
             335
             345
             350],
        ].freeze
        STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(
          init1: :red,
          init2: :green,
          init3: :orange,
          init4: :brightgreen,
          init5: :lightblue,
          init6: :yellow,
          init7: :orange,
          init8: :red,
          init9: :blue,
          init10: :orange,
        ).freeze

        PAR_RANGE = {
          init1: [100],
          init2: [90],
          init3: [82],
          init4: [76],
          init5: [71],
          init6: [67],
          init7: [64],
          init8: [61],
          init9: [58],
          init10: [56],
        }.freeze

        MARKET_TEXT = {
          init1: 'Startkurs LNWR',
          init2: 'Startkurs GWR',
          init3: 'Startkurs Midland',
          init4: 'Startkurs LSWR',
          init5: 'Startkurs GNR',
          init6: 'Startkurs LBSC',
          init7: 'Startkurs GER',
          init8: 'Startkurs GCR',
          init9: 'Startkurs L&YR',
          init10: 'Startkurs SECR',
        }.freeze

        PHASES = [{ name: '2', train_limit: 4, tiles: [:yellow], operating_rounds: 1 },
                  {
                    name: '3',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                    operating_rounds: 2,
                  },
                  {
                    name: '5',
                    on: '5',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                    operating_rounds: 3,
                  },
                  {
                    name: '7',
                    on: '7',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray browngray],
                    operating_rounds: 4,
                    status: ['Private Companies are closed'],
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 180, rusts_on: '5', num: 7 },
                  { name: '3', distance: 3, price: 300, rusts_on: '7', num: 6 },
                  { name: '4', distance: 4, price: 430, num: 5 },
                  {
                    name: '5',
                    distance: 5,
                    price: 450,
                    num: 5,
                  },
                  {
                    name: '7',
                    distance: 7,
                    price: 720,
                    num: 4,
                    events: [{ 'type' => 'close_companies' }],
                  }].freeze

        LAYOUT = :pointy

        def upgrades_to?(from, to, special = false, selected_company: nil)
          # correct color progression?
          return false unless Engine::Tile::COLORS.index(to.color) == (Engine::Tile::COLORS.index(from.color) + 1)
          # honors pre-existing track?
          return false unless from.paths_are_subset_of?(to.paths)
  
          # If special ability then remaining checks is not applicable
          return true if special
  
          # correct label?
          return false unless upgrades_to_correct_label?(from, to)
  
          # honors existing town/city counts?
          # - allow labelled cities to upgrade regardless of count; they're probably
          #   fine (e.g., 18Chesapeake's OO cities merge to one city in brown)
          # - TODO: account for games that allow double dits to upgrade to one town
          return false if from.towns.size != to.towns.size
          return false if !from.label && from.cities.size != to.cities.size
  
          # handle case where we are laying a yellow OO tile and want to exclude single-city tiles
          return false if (from.color == :white) && from.label.to_s == 'OO' && from.cities.size != to.cities.size
  
          true
        end
  
        def operating_round(round_num)
          Round::Operating.new(self, [
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
