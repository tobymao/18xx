# frozen_string_literal: true

require_relative '../config/game/g_1822'
require_relative '../g_1822/company'
require_relative '../g_1822/minor'
require_relative 'base'
require_relative 'stubs_are_restricted'

module Engine
  module Game
    class G1822 < Base
      register_colors(lnwrBlack: '#000',
                      gwrGreen: '#165016',
                      lbscrYellow: '#cccc00',
                      secrOrange: '#ff7f2a',
                      crBlue: '#5555ff',
                      mrRed: '#ff2a2a',
                      lyrPurple: '#2d0047',
                      nbrBrown: '#a05a2c',
                      swrGray: '#999999',
                      nerGreen: '#aade87',
                      black: '#000',
                      white: '#ffffff')

      load_from_json(Config::Game::G1822::JSON)

      DEV_STAGE = :prealpha

      SELL_MOVEMENT = :down_share

      GAME_LOCATION = 'Great Britain'
      GAME_RULES_URL = 'http://google.com'
      GAME_DESIGNER = 'Simon Cutforth'
      GAME_PUBLISHER = :all_aboard_games
      GAME_INFO_URL = 'https://google.com'

      HOME_TOKEN_TIMING = :operating_round
      MUST_BUY_TRAIN = :always
      NEXT_SR_PLAYER_ORDER = :most_cash

      BIDDING_TOKENS = {
        "3": 6,
        "4": 5,
        "5": 4,
        "6": 3,
        "7": 3,
      }.freeze

      BIDDING_TOKENS_PER_ACTION = 3

      include StubsAreRestricted

      attr_accessor :bidding_token_per_player

      def init_companies(_players)
        self.class::COMPANIES.map do |company|
          Engine::G1822::Company.new(self, **company)
        end.compact
      end

      def init_minors
        self.class::MINORS.map do |minor|
          Engine::G1822::Minor.new(**minor)
        end.compact
      end

      def init_round
        stock_round
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::DiscardTrain,
          Step::G1822::BuyTrain,
        ], round_num: round_num)
      end

      def setup
        @bidding_token_per_player = init_bidding_token
        setup_companies
        setup_minors
      end

      def sorted_corporations
        @corporations.select(&:floated?)
      end

      def stock_round
        Round::G1822::Stock.new(self, [
          Step::DiscardTrain,
          Step::Exchange,
          Step::SpecialTrack,
          Step::G1822::BuySellParShares,
        ])
      end

      def bidbox_minors
        @companies.select { |c| c.type == :minor }.map.first(4)
      end

      def bidbox_concessions
        @companies.select { |c| c.type == :concession }.map.first(3)
      end

      def bidbox_privates
        @companies.select { |c| c.type == :private }.map.first(3)
      end

      def init_bidding_token
        self.class::BIDDING_TOKENS[@players.size.to_s]
      end

      def registered_color(color)
        self.class::COLORS[color]
      end

      private

      def setup_companies
        # Randomize from preset seed to get same order
        @companies.sort_by! { rand }

        p1 = @companies.find { |c| !c.nil? && c.id == :P1 }
        @companies.delete(p1)
        @companies.unshift(p1)

        c1 = @companies.find { |c| !c.nil? && c.id == :C1 }
        @companies.delete(c1)
        @companies.unshift(c1)

        m24 = @companies.find { |c| !c.nil? && c.id == '24' }
        @companies.delete(m24)
        @companies.unshift(m24)
      end

      def setup_minors
        # Reserve all the minor cities
        @minors.each do |minor|
          hex = hex_by_id(minor.coordinates)
          hex.tile.add_reservation!(minor, minor.city, nil)
        end
      end
    end
  end
end
