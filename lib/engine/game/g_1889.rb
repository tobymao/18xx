# frozen_string_literal: true

require_relative '../config/game/g_1889'
require_relative '../step/g_1889/special_track'
require_relative 'base'

module Engine
  module Game
    class G1889 < Base
      register_colors(black: '#37383a',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1889::JSON)

      DEV_STAGE = :production

      GAME_LOCATION = 'Shikoku, Japan'
      GAME_RULES_URL = 'http://dl.deepthoughtgames.com/1889-Rules.pdf'
      GAME_DESIGNER = 'Yasutaka Ikeda (池田 康隆)'
      GAME_PUBLISHER = Publisher::INFO[:grand_trunk_games]
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1889'

      EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
      EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
      HOME_TOKEN_TIMING = :operating_round

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::DiscardTrain,
          Step::G1889::SpecialTrack,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::Exchange,
          Step::G1889::SpecialTrack,
          Step::BuySellParShares,
        ])
      end

      def active_players
        return super if @finished

        current_entity == company_by_id('ER') ? [@round.company_seller] : super
      end
    end
  end
end
