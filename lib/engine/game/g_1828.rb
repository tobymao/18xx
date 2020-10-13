# frozen_string_literal: true

require_relative '../config/game/g_1828'
require_relative 'base'

module Engine
  module Game
    class G1828 < Base
      register_colors(hanBlue: '#446CCF',
                      steelBlue: '#4682B4',
                      brick: '#9C661F',
                      powderBlue: '#B0E0E6',
                      khaki: '#F0E68C',
                      darkGoldenrod: '#B8860B',
                      yellowGreen: '#9ACD32',
                      gray70: '#B3B3B3',
                      khakiDark: '#BDB76B',
                      thistle: '#D8BFD8',
                      lightCoral: '#F08080',
                      tan: '#D2B48C',
                      gray50: '#7F7F7F',
                      cinnabarGreen: '#61B329',
                      tomato: '#FF6347',
                      plum: '#DDA0DD',
                      lightGoldenrod: '#EEDD82')

      load_from_json(Config::Game::G1828::JSON)

      DEV_STAGE = :prealpha

      GAME_LOCATION = 'North East, USA'
      GAME_RULES_URL = 'https://github.com/tobymao/18xx/wiki/1828.Games#rules'
      GAME_IMPLEMENTER = 'Chris Rericha based on 1828 by J C Lawrence'
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1828.Games'

      MUST_BID_INCREMENT_MULTIPLE = true
      MIN_BID_INCREMENT = 5

      # TODO: add end game for full OR set in purple phase
      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_round }.freeze

      SELL_BUY_ORDER = :sell_buy_sell

      def self.title
        '1828.Games'
      end

      def new_auction_round
        Round::Auction.new(self, [
          Step::CompanyPendingPar,
          Step::G1828::WaterfallAuction,
        ])
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::SpecialTrack,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def setup
        remove_extra_private_companies
        remove_extra_trains
      end

      def remove_extra_private_companies
        to_remove = companies.find_all { |company| company.value == 250 }
                             .shuffle
                             .pop(7 - @players.size)
        to_remove.each do |company|
          company.close!
          @round.active_step.companies.delete(company)
          @log << "Removing #{company.name}"
        end
      end

      def remove_extra_trains
        return unless @players.size < 5

        to_remove = @depot.trains.find { |train| train.name == '5' }
        @depot.remove_train(to_remove)
        @log << "Removing #{to_remove.name} train"
      end
    end
  end
end
