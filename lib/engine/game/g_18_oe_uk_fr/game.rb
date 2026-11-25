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

        TRAIN_COUNTS = { '2+2' => 10, '3' => 7, '4' => 3, '5' => 3, '6' => 2, '7+7' => 4, '8+8' => 3, PULLMAN => 3 }.freeze
        TRAINS = G18OE::Game::TRAINS.map do |train|
          scenario = train.merge(num: TRAIN_COUNTS.fetch(train[:name], train[:num]))
          scenario[:events] = train[:events].reject { |event| event['type'] == 'minor_d_token' } if train[:events]
          train[:name] == '7+7' ? scenario.merge(events: [{ 'type' => 'level_8_available', 'when' => 1 }]) : scenario
        end.freeze

        MAX_FLOATED_REGIONALS = 6
        PORT_AUTHORITIES = { north_sea: 4, mediterranean: 6 }.freeze
        PORT_AUTHORITY_LIMIT = 2

        PATRONAGE_DRAWS = [{ group: :yellow, zone: 'F', count: 2 }, { group: :pink, zone: 'U', count: 2 }].freeze

        def setup
          super
          @minor_available_regions = { 'UK' => 2, 'FR' => 2 }
        end

        def aggressive_game?
          two_player?
        end
      end
    end
  end
end
