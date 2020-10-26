# frozen_string_literal: true

require_relative '../config/game/g_1860'
require_relative 'base'

module Engine
  module Game
    class G1860 < Base
      register_colors(black: '#000000',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#ff0000',
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

      PAR_RANGE = {
        1 => [74, 100],
        2 => [62, 82],
        3 => [58, 68],
        4 => [54, 62],
      }.freeze

      REPAR_RANGE = {
        1 => [40, 100],
        2 => [40, 82],
        3 => [40, 68],
        4 => [40, 62],
      }.freeze

      LAYER_BY_NAME = {
        'C&N' => 1,
        'IOW' => 1,
        'IWNJ' => 2,
        'FYN' => 2,
        'NGStL' => 3,
        'BHI&R' => 3,
        'S&C' => 4,
        'VYSC' => 4,
      }.freeze

      def setup
        @bankrupt_corps = []
        @receivership_corps = []
        @insolvent_corps = []
        @closed_corps = []
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::Exchange,
          Step::BuySellParShares,
        ])
      end

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

      def new_auction_round
        Round::Auction.new(self, [
          # Step::CompanyPendingPar,
          Step::G1860::BuyCert,
        ])
      end

      def init_round_finished
        players_by_cash = @players.sort_by(&:cash).reverse

        if players_by_cash[0].cash > players_by_cash[1].cash
          player = players_by_cash[0]
          reason = 'most cash'
        else
          # tie-breaker: lowest total face value in private companies
          player = @players.select { |p| p.companies.any? }.min_by { |p| p.companies.sum(&:value) }
          reason = 'least value of private companies'
        end
        @log << "#{player.name} has #{reason}"

        @players.rotate!(@players.index(player))
      end

      def active_players
        return super if @finished

        current_entity == company_by_id('ER') ? [@round.company_seller] : super
      end

      def corp_bankrupt?(corp)
        @bankrupt_corps.include?(corp)
      end

      def corp_hi_par(corp)
        (corp_bankrupt?(corp) ? REPAR_RANGE[corp_layer(corp)] : PAR_RANGE[corp_layer(corp)]).last
      end

      def corp_lo_par(corp)
        (corp_bankrupt?(corp) ? REPAR_RANGE[corp_layer(corp)] : PAR_RANGE[corp_layer(corp)]).first
      end

      def corp_layer(corp)
        LAYER_BY_NAME[corp.name]
      end

      def par_prices(corp)
        par_prices = corp_bankrupt?(corp) ? repar_prices : stock_market.par_prices
        par_prices.select { |p| p.price <= corp_hi_par(corp) && p.price >= corp_lo_par(corp) }
      end

      def repar_prices
        @repar_prices ||= stock_market.market.first.select { |p| p.type == :repar || p.type == :par }
      end
    end
  end
end
