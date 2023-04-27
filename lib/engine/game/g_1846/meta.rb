# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1846
      module Meta
        include Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Thomas Lehmann'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1846'
        GAME_LOCATION = 'Midwest, USA'
        GAME_PUBLISHER = %i[gmt_games golden_spike].freeze
        GAME_RULES_URL = 'https://gmtwebsiteassets.s3.us-west-2.amazonaws.com/1846/1846-RULES-2021.pdf'
        GAME_SUBTITLE = 'The Race for the Midwest'
        GAME_VARIANTS = [
          {
            sym: :two_player,
            name: '2p Variant',
            title: '1846 2p Variant',
            desc: 'unofficial rules for two players',
          },
        ].freeze

        PLAYER_RANGE = [3, 5].freeze
        OPTIONAL_RULES = [
          {
            sym: :first_ed,
            short_name: '1st Edition Private Companies',
            desc: 'Exclude the 2nd Edition companies Boomtown and Little Miami',
            players: [2, 3, 4, 5],
          },
          {
            sym: :second_ed_co,
            short_name: 'Guarantee 2E and C&O',
            desc: 'Ensure that Boomtown, Little Miami, and Chesapeake & Ohio Railroad are not removed during setup.',
            players: [2, 3, 4, 5],
          },
        ].freeze
      end
    end
  end
end
