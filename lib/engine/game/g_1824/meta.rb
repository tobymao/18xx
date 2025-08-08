# frozen_string_literal: true

require_relative '../meta'

module Engine
  module Game
    module G1824
      module Meta
        include Game::Meta

        DEV_STAGE = :prealpha
        DEPENDS_ON = '1837'

        GAME_SUBTITLE = 'Austrian-Hungarian Railway'.freeze
        GAME_DESIGNER = 'Leonhard Orgler & Helmut Ohley'.freeze
        GAME_IMPLEMENTER = 'Per Westling'.freeze
        GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1824'.freeze
        GAME_LOCATION = 'Austria-Hungary'.freeze
        GAME_PUBLISHER = :lonny_games
        GAME_RULES_URL = 'https://boardgamegeek.com/filepage/188242/1824-english-rules'.freeze

        PLAYER_RANGE = [2, 6].freeze
        OPTIONAL_RULES = [
          {
            sym: :cisleithania,
            short_name: 'Cisleithania',
            desc: 'Use the smaller Cislethania map, with some reduction of components - 2-3 players. '\
                  'For 2 players Cistleithania is always used.',
          },
          {
            sym: :goods_time,
            short_name: 'Goods Time',
            desc: 'Use the Goods Time Variant (3-6 players) - pre-set scenario according to the rulebook.',
          },
        ].freeze

        def self.check_options(options, _min_players, max_players)
          optional_rules = (options || []).map(&:to_sym)
          if optional_rules.include?(:cisleithania) && !max_players.nil? && (max_players > 3)
            { error: 'Cisleithania variant is for 2-3 players' }
          elsif optional_rules.include?(:cisleithania) && optional_rules.include?(:goods_time)
            { error: 'Cisleithania and Goods Time combined not supported' }
          end
        end
      end
    end
  end
end
