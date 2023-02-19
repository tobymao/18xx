# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_18_ny/meta'

module Engine
  module Game
    module G18NY1E
      module Meta
        include Game::Meta
        include G18NY::Meta

        DEPENDS_ON = '18NY'.freeze
        GAME_IS_VARIANT_OF = G18NY::Meta

        GAME_PUBLISHER = :golden_spike
        GAME_RULES_URL = 'https://drive.google.com/file/d/0B1SWz2pNe2eAWG9NRVYzS3FUc28/view?resourcekey=0-4MvZ7w-dGc_esikxhR8rvw'.freeze
        GAME_TITLE = '18NY 1st Edition'.freeze
        GAME_VARIANTS = [].freeze
        GAME_ISSUE_LABEL = '18NY'

        def self.fs_name
          @fs_name ||= 'g_18_ny_1e'
        end
      end
    end
  end
end
