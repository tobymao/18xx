# frozen_string_literal: true

require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative 'market'
require_relative 'trains'
require_relative '../base'
require_relative '../stubs_are_restricted'

module Engine
  module Game
    module G1858
      class Game < Game::Base
        include_meta(G1858::Meta)
        include G1858::Map
        include G1858::Entities
        include G1858::Market
        include G1858::Trains
        include StubsAreRestricted

        GAME_END_CHECK = { bank: :current_or }.freeze
        BANKRUPTCY_ALLOWED = false

        MIN_BID_INCREMENT = 5
        MUST_BID_INCREMENT_MULTIPLE = true

        HOME_TOKEN_TIMING = :float
        TRACK_RESTRICTION = :semi_restrictive
        TILE_UPGRADES_MUST_USE_MAX_EXITS = %i[cities].freeze

        MUST_BUY_TRAIN = :never
        EBUY_DEPOT_TRAIN_MUST_BE_CHEAPEST = false
        EBUY_OTHER_VALUE = false
        MUST_EMERGENCY_ISSUE_BEFORE_EBUY = false
        EBUY_SELL_MORE_THAN_NEEDED = false
        EBUY_SELL_MORE_THAN_NEEDED_LIMITS_DEPOT_TRAIN = true
        EBUY_OWNER_MUST_HELP = true
        EBUY_CAN_SELL_SHARES = false

        MINOR_TILE_LAYS = [
          { lay: true, upgrade: false },
          { lay: true, upgrade: false, cost: 20, cannot_reuse_same_hex: true },
        ].freeze
        TILE_LAYS = [
          { lay: true, upgrade: true },
          { lay: true, upgrade: true, cost: 20, cannot_reuse_same_hex: true },
        ].freeze
      end
    end
  end
end
