# frozen_string_literal: true

require_relative '../g_1849/game'
require_relative 'meta'

module Engine
  module Game
    module G18Ireland
      class Game < G1849::Game
        include_meta(G18Ireland::Meta)

        CURRENCY_FORMAT_STR = '£%d'

        BANK_CASH = 4000

        CERT_LIMIT = { 3 => 16, 4 => 12, 5 => 10, 6 => 8 }.freeze

        STARTING_CASH = { 3 => 330, 4 => 250, 5 => 200, 6 => 160 }.freeze
      end
    end
  end
end
