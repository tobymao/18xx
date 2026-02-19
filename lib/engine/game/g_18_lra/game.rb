# frozen_string_literal: true

require_relative 'map'
require_relative 'meta'
require_relative '../g_18_rhl/game'

module Engine
  module Game
    module G18Lra
      class Game < G18Rhl::Game
        include_meta(G18Lra::Meta)
        include Map

        BANK_CASH = { 2 => 6000, 3 => 6000, 4 => 8000 }.freeze

        CERT_LIMIT = { 2 => 14, 3 => 14, 4 => 15 }.freeze

        STARTING_CASH = { 2 => 600, 3 => 600, 4 => 450 }.freeze
        LOWER_STARTING_CASH = { 2 => 500, 3 => 500, 4 => 375 }.freeze

        def num_trains(train)
          case train[:name]
          when '2'
            optional_2_train ? 6 : 5
          when '3'
            4
          when '4', '5'
            2
          when '6'
            6
          when '8'
            0
          end
        end
      end
    end
  end
end
