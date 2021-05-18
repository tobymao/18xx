# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18ZOO
      module SharedMeta
        include Engine::Game::Meta

        DEV_STAGE = :alpha

        GAME_DESIGNER = 'Paolo Russo'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18ZOO'
        GAME_RULES_URL = {
          '18ZOO Rules' =>
            'https://boardgamegeek.com/filepage/219443/complete-rules-layout-standard',
          'Stock Market extract' =>
            'https://boardgamegeek.com/filepage/219446/stock-board-details-playing-18xxgames',
          'Intro guide' =>
            'https://boardgamegeek.com/thread/2660017/article/37718069#37718069',
        }.freeze

        OPTIONAL_RULES = [
          {
            sym: :power_visible,
            short_name: 'Powers visible',
            desc: 'Next powers are visible since the beginning.',
          },
        ].freeze
      end

      module Meta
        include Engine::Game::Meta
        include G18ZOO::SharedMeta

        GAME_TITLE = '18ZOO'

        GAME_VARIANTS = [
          {
            sym: :map_b,
            name: 'Map B',
            title: '18ZOO - Map B',
            desc: 'Map with 5 families',
          },
          {
            sym: :map_c,
            name: 'Map C',
            title: '18ZOO - Map C',
            desc: 'Map with 5 families',
          },
          {
            sym: :map_d,
            name: 'Map D',
            title: '18ZOO - Map D',
            desc: 'Map with 7 families',
          },
          {
            sym: :map_e,
            name: 'Map E',
            title: '18ZOO - Map E',
            desc: 'Map with 7 families',
          },
          {
            sym: :map_f,
            name: 'Map F',
            title: '18ZOO - Map F',
            desc: 'Map with 7 families',
          },
        ].freeze

        PLAYER_RANGE = [2, 4].freeze
      end
    end

    module G18ZOOMapB
      module Meta
        include Engine::Game::Meta
        include G18ZOO::SharedMeta

        DEPENDS_ON = '18ZOO'

        GAME_TITLE = '18ZOO - Map B'
        GAME_IS_VARIANT_OF = G18ZOO::Meta

        PLAYER_RANGE = [2, 4].freeze
      end
    end

    module G18ZOOMapC
      module Meta
        include Engine::Game::Meta
        include G18ZOO::SharedMeta

        DEPENDS_ON = '18ZOO'

        GAME_TITLE = '18ZOO - Map C'
        GAME_IS_VARIANT_OF = G18ZOO::Meta

        PLAYER_RANGE = [2, 4].freeze
      end
    end

    module G18ZOOMapD
      module Meta
        include Engine::Game::Meta
        include G18ZOO::SharedMeta

        DEPENDS_ON = '18ZOO'

        GAME_TITLE = '18ZOO - Map D'
        GAME_IS_VARIANT_OF = G18ZOO::Meta

        PLAYER_RANGE = [2, 5].freeze
      end
    end

    module G18ZOOMapE
      module Meta
        include Engine::Game::Meta
        include G18ZOO::SharedMeta

        DEPENDS_ON = '18ZOO'

        GAME_TITLE = '18ZOO - Map E'
        GAME_IS_VARIANT_OF = G18ZOO::Meta

        PLAYER_RANGE = [2, 5].freeze
      end
    end

    module G18ZOOMapF
      module Meta
        include Engine::Game::Meta
        include G18ZOO::SharedMeta

        DEPENDS_ON = '18ZOO'

        GAME_TITLE = '18ZOO - Map F'
        GAME_IS_VARIANT_OF = G18ZOO::Meta

        PLAYER_RANGE = [2, 5].freeze
      end
    end
  end
end
