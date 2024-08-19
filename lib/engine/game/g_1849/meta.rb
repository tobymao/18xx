# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1849
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_SUBTITLE = 'The Game of Sicilian Railways'
        GAME_DESIGNER = 'Federico Vellani'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1849'
        GAME_LOCATION = 'Sicily'
        GAME_PUBLISHER = :all_aboard_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/206628/1849-rules'

        PLAYER_RANGE = [3, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :delay_ift,
            short_name: 'Delay IFT',
            desc: 'IFT may not be one of the first three corporations (recommended for newer players)',
          },
          {
            sym: :reduced_4p_corps,
            short_name: 'Reduced corps at 4 players',
            desc: 'Six corporations are recommended in a 4-player game, but it is possible to play with five',
          },
          {
            sym: :acquiring_station_tokens,
            short_name: 'Buy tokens',
            desc: 'Corporations can buy station tokens from other corporations',
          },
          {
            sym: :bonds,
            short_name: 'Bonds',
            desc: 'Corporations have a single L.500 bond they can issue',
          },
          {
            sym: :electric_dreams,
            short_name: 'Electric Dreams',
            desc: 'Adds E-trains that run infinite distance on broad track and double select cities',
          },
        ].freeze

        def self.check_options(options, _min_players, _max_players)
          optional_rules = (options || []).map(&:to_sym)

          return if optional_rules.empty?

          if optional_rules.include?(:electric_dreams) &&
            (!optional_rules.include?(:bonds) || !optional_rules.include?(:acquiring_station_tokens))
            { error: 'Electric Dreams variant requires the Bonds and Buy Tokens variants as well.' }
          end
        end
      end
    end
  end
end
