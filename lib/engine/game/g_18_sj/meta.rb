# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18SJ
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        PROTOTYPE = true

        GAME_SUBTITLE = 'Let There Be Rail (version 0.92)'
        GAME_DESIGNER = 'Örjan Wennman'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18SJ'
        GAME_LOCATION = 'Sweden and Norway'
        GAME_PUBLISHER = :self_published
        GAME_RULES_URL = 'https://cdn.fbsbx.com/v/t59.2708-21/279939909_494748305728726_6506703077215187468_n.pdf/'\
                         '18SJ-Rules-Wennman-v0.92.pdf?_nc_cat=105&ccb=1-6&_nc_sid=0cab14&_nc_ohc=sBPaJrIhnkkAX-dUyK2'\
                         '&_nc_ht=cdn.fbsbx.com&oh=03_AVIlN9BOtWlHLkvoTB256JQAE1C1fJFBkh5HI3pFXO9icg&oe=627D771F&dl=1'

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :oscarian_era,
            short_name: 'The Oscarian Era',
            desc: 'Full cap only, sell even if not floated',
          },
          {
            sym: :two_player_variant,
            short_name: 'A.W. Edelswärds 2 Player Variant',
            desc: 'A.W. Edelswärd "bot" plays the 3rd player',
            players: [2],
          },
        ].freeze
      end
    end
  end
end
