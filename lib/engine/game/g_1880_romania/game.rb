# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1880/game'
require_relative 'map'
require_relative 'entities'
require_relative 'phases'
require_relative 'trains'

module Engine
  module Game
    module G1880Romania
      class Game < G1880::Game
        include_meta(G1880Romania::Meta)
        include G1880Romania::Map
        include G1880Romania::Entities
        include G1880Romania::Phases
        include G1880Romania::Trains

        CURRENCY_FORMAT_STR = 'L%s'

        CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 14, 6 => 12 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 480, 5 => 400, 6 => 340 }.freeze

        SIBIU_HEX = 'F11'

        EVENTS_TEXT = G1880::Game::EVENTS_TEXT.merge(
          'signal_end_game' => ['Signal End Game', 'Game ends 3 ORs after purchase of last 6E train']
        ).freeze

        def stock_round
          G1880Romania::Round::Stock.new(self, [
            Engine::Step::Exchange,
            G1880::Step::BuySellParShares,
          ])
        end
      end
    end
  end
end
