# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18LosAngeles
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        DEPENDS_ON = '1846'

        GAME_DESIGNER = 'Anthony Fryer'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18LosAngeles'
        GAME_PUBLISHER = :traxx
        GAME_LOCATION = 'LA County, California, USA'
        GAME_RULES_URL = {
          '18 Los Angeles 2nd Edition Rules' =>
                          'https://drive.google.com/file/d/1mno-8gmYlSjUSB91IcfW_Pvtcr1xUWiy/view?usp=sharing',
          '1846 Rules' =>
                'https://s3-us-west-2.amazonaws.com/gmtwebsiteassets/1846/1846-RULES-GMT.pdf',
        }.freeze
        GAME_TITLE = '18 Los Angeles 2'
        GAME_DISPLAY_TITLE = '18 Los Angeles'
        GAME_FULL_TITLE = '18 Los Angeles: Railroading in the City of Angels 2nd Edition'
        GAME_ALIASES = %w[18LA 18LA_2].freeze
        GAME_ISSUE_LABEL = '18 Los Angeles'
        GAME_VARIANTS = [
          {
            sym: :first_ed,
            name: 'First Edition',
            title: '18 Los Angeles',
          },
        ].freeze

        PLAYER_RANGE = [2, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :dch,
            short_name: 'Dewey, Cheatham, and Howe',
            desc: 'add a private company which allows the owning corporation to '\
                  'place a token in a city that has no open slots; 3+ players only',
            players: [3, 4, 5],
          },
          {
            sym: :la_title,
            short_name: 'LA Title',
            desc: 'add a private company which can lay an Open City token; 3+ players only',
            players: [3, 4, 5],
          },
        ].freeze
      end
    end
  end
end
