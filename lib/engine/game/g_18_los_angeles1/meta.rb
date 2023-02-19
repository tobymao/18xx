# frozen_string_literal: true

require_relative '../meta'
require_relative '../g_18_los_angeles/meta'

module Engine
  module Game
    module G18LosAngeles1
      module Meta
        include Game::Meta
        include G18LosAngeles::Meta

        DEV_STAGE = :production
        DEPENDS_ON = '18 Los Angeles 2'

        GAME_PUBLISHER = %i[traxx].freeze

        GAME_RULES_URL = {
          '18 Los Angeles 1st Edition Rules' =>
                          'https://drive.google.com/file/d/16di_KBlGYnmdAMvjl2ZiqvyeB7wTAJ_4/view?usp=sharing',
          '1846 Rules' =>
                'https://s3-us-west-2.amazonaws.com/gmtwebsiteassets/1846/1846-RULES-GMT.pdf',
        }.freeze
        GAME_TITLE = '18 Los Angeles'
        GAME_DISPLAY_TITLE = '18 Los Angeles 1'
        GAME_FULL_TITLE = '18 Los Angeles: Railroading in the City of Angels 1st Edition'
        GAME_ISSUE_LABEL = '18 Los Angeles'
        GAME_IS_VARIANT_OF = G18LosAngeles::Meta
        GAME_ALIASES = ['18LA_1'].freeze
        GAME_VARIANTS = [].freeze
      end
    end
  end
end
