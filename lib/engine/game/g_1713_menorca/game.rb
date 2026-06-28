# frozen_string_literal: true

require_relative 'meta'
require_relative 'companies'
require_relative 'map'
require_relative 'market'
require_relative 'phases'
require_relative 'privates'
require_relative 'tiles'
require_relative 'trains'
require_relative '../base'

module Engine
  module Game
    module G1713Menorca
      class Game < Game::Base
        include_meta(G1713Menorca::Meta)
        include Companies
        include Map
        include Market
        include Phases
        include Privates
        include Tiles
        include Trains

        CURRENCY_FORMAT_STR = '%sR'
        BANK_CASH    = 7000
        CERT_LIMIT   = { 2 => 15, 3 => 13 }.freeze
        STARTING_CASH = { 2 => 420, 3 => 380 }.freeze
        CAPITALIZATION   = :incremental


        BANKRUPTCY_ALLOWED = true
        BANKRUPTCY_ENDS_GAME_AFTER = :all_but_one

        GAME_END_CHECK = { bankrupt: :immediate, bank: :full_or }.freeze
        GAME_END_TIMING_PRIORITY = %i[immediate current_or after_max_operates full_or].freeze

      end
    end
  end
end
