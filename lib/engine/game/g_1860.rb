# frozen_string_literal: true

require_relative '../config/game/g_1860'
require_relative 'base'

module Engine
  module Game
    class G1860 < Base
      register_colors(black: '#37383a',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1860::JSON)

      GAME_LOCATION = 'Isle of Wight'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/79633/second-edition-rules'
      GAME_DESIGNER = 'Mike Hutton'
      GAME_PUBLISHER = Publisher::INFO[:zman_games]
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1860'

      EBUY_PRES_SWAP = false # allow presidential swaps of other corps when ebuying
      EBUY_OTHER_VALUE = false # allow ebuying other corp trains for up to face
      HOME_TOKEN_TIMING = :operating_round

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::DiscardTrain,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
        ], round_num: round_num)
      end

      def init_stock_market
        StockMarket.new(self.class::MARKET, [], zigzag: true)
      end

      def active_players
        return super if @finished

        current_entity == company_by_id('ER') ? [@round.company_seller] : super
      end
    end
  end
end
