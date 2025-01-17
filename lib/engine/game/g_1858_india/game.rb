# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../g_1858/game'

module Engine
  module Game
    module G1858India
      class Game < G1858::Game
        include_meta(G1858India::Meta)
        include Entities
        include Map

        CURRENCY_FORMAT_STR = '£%s'
        BANK_CASH = 16_000
        STARTING_CASH = { 3 => 665, 4 => 500, 5 => 400, 6 => 335 }.freeze
        CERT_LIMIT = { 3 => 27, 4 => 20, 5 => 16, 6 => 13 }.freeze
      end
    end
  end
end
