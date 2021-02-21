# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1817WO
      module Meta
        include Game::Meta

        DEV_STAGE = :production
        DEPENDS_ON = '1817'

        GAME_DESIGNER = 'Mark Voyer & Brennan Sheremeto'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1817WO'
        GAME_LOCATION = 'Earth.'
        GAME_RULES_URL = {
          '1817WO' =>
                          'https://docs.google.com/document/d/1g9QnttpJa8yOCOTnfPaU9hfAZFFzg-rAs_WGy9T38J0/',
          '1817 Rules' =>
                'https://drive.google.com/file/d/0B1SWz2pNe2eAbnI4NVhpQXV4V0k/view',
        }.freeze
        GAME_TITLE = '1817WO'

        PLAYER_RANGE = [2, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :short_squeeze,
            short_name: 'Short Squeeze',
            desc: 'Corporations with > 100% player ownership move a second time at end of SR',
          },
          {
            sym: :five_shorts,
            short_name: '5 Shorts',
            desc: 'Only allow 5 shorts on 10 share corporations',
          },
          {
            sym: :modern_trains,
            short_name: 'Modern Trains',
            desc: '7 & 8 trains earn $10 & $20 respectively for each station marker of the corporation',
          },
        ].freeze
      end
    end
  end
end
