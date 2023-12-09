# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1868WY
      module Meta
        include Game::Meta

        DEV_STAGE = :beta

        GAME_DESIGNER = 'John Harres'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1868-Wyoming'
        GAME_PUBLISHER = :mercury
        GAME_RULES_URL = {
          'Rules' => 'https://boardgamegeek.com/filepage/262791/rules-traxx-mainline-hell-wheels-ks-release',
          'Rules Highlights (2 pages)' => 'https://boardgamegeek.com/filepage/262792/rules-highlights',
        }.freeze
        GAME_LOCATION = 'Wyoming, USA'
        GAME_TITLE = '1868 Wyoming'
        GAME_FULL_TITLE = '1868: Boom and Bust in the Coal Mines and Oil Fields of Wyoming'
        GAME_ISSUE_LABEL = '1868WY'

        PLAYER_RANGE = [2, 5].freeze

        OPTIONAL_RULES = [
          {
            sym: :async_friendly,
            short_name: 'Async-friendly Dev Rounds',
            desc: 'In Development Rounds from phase 5, players go through the Stock '\
                  'Round order once to place Coal and Oil tokens together, instead '\
                  'of going through the order once for Coal and another time for Oil.',
          },
          {
            sym: :p2_p6_choice,
            short_name: 'P2-P6 choice',
            desc: 'The winners of the privates P2 through P6 in the auction choose to take one of '\
                  'the three corresponding private companies, rather than those being randomly '\
                  'chosen during setup.',
          },
          {
            sym: :simple_2p,
            short_name: 'Simple 2p Variant',
            title: '1868 Wyoming Simple 2p',
            desc: 'Adjusted cert limit and starting cash instead of using the 2-player rules from '\
                  'section 11 of the rulebook. Ignored if the game is started with more than 2 players.',
          },
        ].freeze

        def self.check_options(options, min_players, max_players, mode)
          optional_rules = (options || []).map(&:to_sym)

          min_players = mode == :hotseat ? (max_players || 5) : (min_players || 2)

          if min_players == 2 && !optional_rules.include?(:simple_2p)
            puts 'The standard 2p rules are not implemented. Increase "Min Players" or select "Simple 2p Variant."'

            return { error: 'The standard 2p rules are not implemented. Increase "Min Players" or select "Simple 2p Variant."' }
          end
        end
      end
    end
  end
end
