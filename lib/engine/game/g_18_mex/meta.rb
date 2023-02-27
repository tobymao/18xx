# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18MEX
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Mark Derrick'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18MEX'
        GAME_LOCATION = 'Mexico'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://drive.google.com/file/d/17ahTfEG04vHhLiJ8fVsp2ya_-pCEt6q0/view?usp=sharing'

        PLAYER_RANGE = [3, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :triple_yellow_first_or,
            short_name: 'Extra yellow',
            desc: 'Allow corporations to lay 3 yellow tiles their first OR',
          },
          {
            sym: :early_buy_of_kcmo,
            short_name: 'Early buy of KCM&O private',
            desc: 'KCM&O private may be bought in for up to face value',
          },
          {
            sym: :delay_minor_close,
            short_name: 'Delay minor close',
            desc: "Minor closes at the start of the SR following buy of first 3'",
          },
          {
            sym: :hard_rust_t4,
            short_name: 'Hard rust',
            desc: "4 trains rust when 6' train is bought",
          },
          {
            sym: :baja_variant,
            short_name: 'Baja Variant',
            desc: 'adds a private company which provides a teleport token to a new map hex.',
          },
        ].freeze
      end
    end
  end
end
