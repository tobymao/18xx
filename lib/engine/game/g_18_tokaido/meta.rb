# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G18Tokaido
      module Meta
        include Engine::Game::Meta

        DEV_STAGE = :beta
        PROTOTYPE = true
        DEPENDS_ON = '18 Los Angeles'

        GAME_TITLE = '18Tokaido'
        GAME_ISSUE_LABEL = '18Tokaido'
        GAME_DESIGNER = 'Douglas Triggs'
        GAME_LOCATION = 'Central Japan'
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18Tokaido'
        # For now
        GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/18Tokaido'

        PLAYER_RANGE = [2, 4].freeze

        OPTIONAL_RULES = [
          {
            sym: :newbie_rules,
            short_name: 'Local 普通',
            desc: '[newbie variant] slightly expanded tileset, removes yellow zone from stock market',
          },
          {
            sym: :limited_express,
            short_name: 'Limited Express 特急',
            desc: '[brutal variant] one less 6 train, 50% to float, 1882-like stock market',
          },
          {
            sym: :pass_priority,
            short_name: 'Pass Priority',
            players: [3, 4],
            desc: 'player order in stock round determined by order of passing in previous stock round',
          },
          {
            sym: :no_corporation_discard,
            short_name: 'No Discard',
            players: [2, 3],
            desc: 'skips removing a random railroad corporation from the game',
          },
          {
            sym: :snake_draft,
            short_name: 'Snake Draft',
            desc: 'snake draft for privates',
          },
          {
            sym: :waterfall_auction,
            short_name: 'Waterfall Auction',
            desc: 'standard waterfall auction for privates',
          },
        ].freeze

        MUTEX_RULES = [
          %i[snake_draft waterfall_auction],
          %i[limited_express newbie_rules],
        ].freeze
      end
    end
  end
end
