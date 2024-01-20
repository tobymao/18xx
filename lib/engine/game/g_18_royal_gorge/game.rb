# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative 'trains'

module Engine
  module Game
    module G18RoyalGorge
      class Game < Game::Base
        include_meta(G18RoyalGorge::Meta)
        include Entities
        include Map
        include Trains

        CURRENCY_FORMAT_STR = '$%s'
        BANK_CASH = 99_999
        CERT_LIMIT = { 2 => 20, 3 => 14, 4 => 10 }.freeze
        STARTING_CASH = { 2 => 800, 3 => 550, 4 => 400 }.freeze

        STOCKMARKET_COLORS = {
          par: :yellow,
          par_1: :green,
          par_2: :brown,
          endgame: :red,
        }.freeze
        MARKET = [
          %w[30 35 40 45 50 55 60p 65p 70p 80p 90x 100x 110x 120x 130z 145z 160z 180z 200 220 240 260 280 310e 340e 380e 420e
             460e],
        ].freeze
        MARKET_TEXT = Base::MARKET_TEXT.merge(par: 'Par values in Yellow Phase',
                                              par_1: 'Additional par values in Green Phase',
                                              par_2: 'Additional par values in Brown Phase').freeze
        MUST_SELL_IN_BLOCKS = true
        SELL_BUY_ORDER = :sell_buy

        TILE_LAYS = ([{ lay: true, upgrade: true, cost: 0 }] * 6).freeze
        MUST_BUY_TRAIN = :always
        CAPITALIZATION = :incremental

        def ipo_name(_entity = nil)
          'Treasury'
        end
      end
    end
  end
end
