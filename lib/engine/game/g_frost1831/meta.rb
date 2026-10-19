# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module GFrost1831
      module Meta
        include Game::Meta

        DEV_STAGE = :alpha

        GAME_TITLE = 'Frost 1831'.freeze
        GAME_ISSUE_LABEL = 'frost1831'
        FIXTURE_DIR_NAME = 'frost1831'

        GAME_DESIGNER = 'Alexandre Madu'.freeze
        GAME_IMPLEMENTER = 'Lucas Leite'.freeze

        GAME_INFO_URL = nil
        GAME_LOCATION = 'New London'.freeze
        GAME_PUBLISHER = nil
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/331178/rulebook-v0933'
        GAME_ALIASES = ['1831'].freeze

        PLAYER_RANGE = [2, 5].freeze

        OPTIONAL_RULES = [
          {
            sym: :parliamentary_intervention,
            short_name: 'Parliamentary Intervention',
            desc: "Player's 2nd corporation must support at least 1 faction different from the 1st corporation",
          },
          {
            sym: :tight_government,
            short_name: 'Tight Government',
            desc: 'All regulations start at Tight position (R1-R4 = 2)',
          },
          {
            # Legacy flag, no longer selectable when creating a game. Existing
            # games that were created with it keep the extra 3-train; new games
            # cannot choose it.
            sym: :extra_train,
            short_name: 'Extra 3-Train (legacy)',
            desc: 'Add one additional 3-train to the game (6 total instead of 5)',
            hidden: true,
          },
          {
            # Legacy flag, not selectable when creating a game. Games created
            # before the endgame change carry this so they still end on the first
            # D train purchase. New games end only when the bank breaks.
            sym: :d_train_endgame,
            short_name: 'D Train Endgame (legacy)',
            desc: 'Game ends on the first D train purchase (legacy games only)',
            hidden: true,
          },
          {
            # Legacy flag, not selectable when creating a game. Games created
            # before this change auto-pick the 2nd supported faction when only
            # one option remains. New games always ask the player to choose.
            sym: :auto_second_faction,
            short_name: 'Auto 2nd Faction (legacy)',
            desc: 'Automatically pick the 2nd supported faction when only one option remains (legacy games only)',
            hidden: true,
          },
        ].freeze
      end
    end
  end
end
