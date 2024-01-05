# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18PA
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha

        GAME_SUBTITLE = 'The Dawn of Rail: Empire Building From the Seaboard to the Ohio'
        GAME_DESIGNER = 'David G.D. Hecht'
        GAME_LOCATION = 'Pennsylvania, USA'
        GAME_PUBLISHER = :golden_spike
        GAME_RULES_URL = 'https://drive.google.com/file/d/0B_EQlMlnpxy3YnNTVkZ2X0ZmNlE/view?usp=sharing&resourcekey=0-erJnA4q7r-x1p-s0As8K-g'

        PLAYER_RANGE = [3, 5].freeze
      end
    end
  end
end
