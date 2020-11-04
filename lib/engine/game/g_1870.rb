# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# frozen_string_literal: true

require_relative '../config/game/g_1870'
require_relative 'base'

module Engine
  module Game
    class G1870 < Base
      register_colors(black: '#37383a',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1870::JSON)

      GAME_LOCATION = 'Mississippi, USA'
      GAME_RULES_URL = 'http://www.hexagonia.com/rules/MFG_1870.pdf'
      GAME_DESIGNER = 'Bill Dixon'
      GAME_PUBLISHER = :mayfair_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1870'

      EBUY_PRES_SWAP = false
      EBUY_OTHER_VALUE = false

      TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }, { lay: :not_if_upgraded, upgrade: false, cost: 0 }].freeze

      STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(unlimited: :green).merge(close: :white).freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge('remove_tokens' => ['Remove Tokens', 'Remove private company tokens']).freeze

      ASSIGNMENT_TOKENS = {
        'GSC' => '/icons/1846/mpc_token.svg',
        'SCC' => '/icons/1846/sc_token.svg',
      }.freeze

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

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
