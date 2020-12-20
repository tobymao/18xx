# frozen_string_literal: true

require_relative '../config/game/g_18_cz'
require_relative 'base'

module Engine
  module Game
    class G18CZ < Base
      load_from_json(Config::Game::G18CZ::JSON)

      DEV_STAGE = :prealpha
      GAME_LOCATION = 'Czech Republic'
      GAME_RULES_URL = 'http://ohley.de/english/1848/1848-rules.pdf'
      GAME_DESIGNER = 'Leonhard Orgler and Helmut Ohley'
      GAME_PUBLISHER = :oo_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1848'

      # Two tiles can be laid at a time, with max one upgrade
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: true, upgrade: :not_if_upgraded }].freeze

      SELL_BUY_ORDER = :sell_buy
      SELL_MOVEMENT = :down_block

      HOME_TOKEN_TIMING = :operate

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::DiscardTrain,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end
    end
  end
end
