# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18ZOO
      module SharedMeta
        include Engine::Game::Meta

        DEV_STAGE = :production

        GAME_DESIGNER = 'Paolo Russo'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18ZOO'
        GAME_RULES_URL = {
          '18ZOO Rules' =>
            'https://boardgamegeek.com/filepage/219443/complete-rules-layout-standard',
          'Stock Market extract' =>
            'https://cf.geekdo-images.com/KGlFUsaWc3P_4TQEUPGIWw__imagepage/img/l0dTWH1jFaO7v5IRFyBByoFsNnM='\
            '/fit-in/900x600/filters:no_upscale():strip_icc()/pic6153038.png',
          'Intro guide' =>
            'https://boardgamegeek.com/thread/2660017/article/37718069#37718069',
          'FAQ' =>
            'https://boardgamegeek.com/thread/2661280/faq',
        }.freeze
        GAME_ISSUE_LABEL = '18ZOO'

        OPTIONAL_RULES = [
          {
            sym: :power_visible,
            short_name: 'Powers visible',
            desc: 'Next powers are visible since the beginning.',
          },
          {
            sym: :base_2,
            short_name: 'Base 2',
            desc: 'Center map with ”less money”. If both Base 2 and Base 3 are selected, it is applied Base 3 only',
          },
          {
            sym: :base_3,
            short_name: 'Base 3',
            desc: 'Center map with ”more money”. If both Base 2 and Base 3 are selected, it is applied Base 3 only',
          },
        ].freeze
      end

      module Meta
        include Engine::Game::Meta
        include G18ZOO::SharedMeta

        GAME_TITLE = '18ZOO'
        GAME_FULL_TITLE = '18ZOO - Map A (2-3 players) / Map D (4-5 players)'

        GAME_VARIANTS = [
          {
            sym: :map_a,
            name: 'Map A',
            title: '18ZOO - Map A',
            desc: '5 corporations, suggested for 2-3 players',
          },
          {
            sym: :map_b,
            name: 'Map B',
            title: '18ZOO - Map B',
            desc: '5 corporations, suggested for 2-3 players',
          },
          {
            sym: :map_c,
            name: 'Map C',
            title: '18ZOO - Map C',
            desc: '5 corporations, suggested for 2-3 players',
          },
          {
            sym: :map_d,
            name: 'Map D',
            title: '18ZOO - Map D',
            desc: '7 corporations, suggested for 4-5 players',
          },
          {
            sym: :map_e,
            name: 'Map E',
            title: '18ZOO - Map E',
            desc: '7 corporations, suggested for 4-5 players',
          },
          {
            sym: :map_f,
            name: 'Map F',
            title: '18ZOO - Map F',
            desc: '7 corporations, suggested for 4-5 players',
          },
        ].freeze

        PLAYER_RANGE = [2, 5].freeze
      end
    end

    module G18ZOOMapA
      module Meta
        include Engine::Game::Meta
        include G18ZOO::SharedMeta

        DEPENDS_ON = '18ZOO'

        GAME_TITLE = '18ZOO - Map A'
        GAME_IS_VARIANT_OF = G18ZOO::Meta

        PLAYER_RANGE = [2, 5].freeze
      end
    end

    module G18ZOOMapB
      module Meta
        include Engine::Game::Meta
        include G18ZOO::SharedMeta

        DEPENDS_ON = '18ZOO'

        GAME_TITLE = '18ZOO - Map B'
        GAME_IS_VARIANT_OF = G18ZOO::Meta

        PLAYER_RANGE = [2, 5].freeze
      end
    end

    module G18ZOOMapC
      module Meta
        include Engine::Game::Meta
        include G18ZOO::SharedMeta

        DEPENDS_ON = '18ZOO'

        GAME_TITLE = '18ZOO - Map C'
        GAME_IS_VARIANT_OF = G18ZOO::Meta

        PLAYER_RANGE = [2, 5].freeze
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
