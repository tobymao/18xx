# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1822
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'The Railways of Great Britain'
        GAME_DESIGNER = 'Simon Cutforth'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1822'
        GAME_LOCATION = 'Great Britain'
        GAME_PUBLISHER = :all_aboard_games
        GAME_VARIANTS = [
          {
            sym: :nrs,
            name: 'North Regional Scenario',
            title: '1822NRS',
            desc: 'shorter game on the northern part of the map',
          },
          {
            sym: :mrs,
            name: 'Medium Regional Scenario',
            title: '1822MRS',
            desc: 'shorter game on the southern part of the map',
          },
        ].freeze
        GAME_RULES_URL = {
          'Rules' => 'https://boardgamegeek.com/filepage/219065/1822-railways-great-britain-rules',
          '2-player rules (BGG thread)' => 'https://boardgamegeek.com/thread/2429917/article/34848979#34848979',
        }.freeze

        PLAYER_RANGE = [2, 7].freeze

        OPTIONAL_RULES = [
          {
            sym: :plus_expansion,
            short_name: '1822+',
            desc: '6 more minors and 3 more privates. The privates are categorized into trains (bidbox 1), track '\
                  '(bidbox 2) and other (bidbox 3) stacks.',
          },
          {
            sym: :plus_expansion_no_removals,
            short_name: 'No Removals',
            desc: '(1822+) Use all 21 private companies instead of removing 3. ',
          },
          {
            sym: :plus_expansion_single_stack,
            short_name: 'Single Stack',
            desc: '(1822+) The privates are not categorized, and fill the 3 bidboxes as in base 1822.',
          },
          {
            sym: :tax_haven_multiple,
            short_name: 'Tax Haven Variant',
            desc: 'P16 (Tax Haven) can use the cash it accumulates to buy 1 share per SR. Cannot '\
                  'own multiple shares of one corporation. To ensure P16 is present in 1822+, use '\
                  'the "No Removals" variant.',
          },
        ].freeze
      end
    end
  end
end
