# frozen_string_literal: true

require_relative '../g_18_oe/game'
require_relative 'meta'
require_relative 'map'
require_relative 'entities'

module Engine
  module Game
    module G18OEUKFR
      class Game < G18OE::Game
        include_meta(G18OEUKFR::Meta)
        include G18OEUKFR::Entities
        include G18OEUKFR::Map

        CERT_LIMIT = { 2 => 24, 3 => 16 }.freeze
        STARTING_CASH = { 2 => 870, 3 => 580 }.freeze
        BANK_CASH = 18_000
      end
    end
  end
end
