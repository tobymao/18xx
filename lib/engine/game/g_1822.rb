# frozen_string_literal: true

require_relative '../config/game/g_1822'
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

      def entity_can_use_company?(_entity, company)
        # Setting bidding companies owner to bank, make sure the abilities dont show for theese
        company.owner != @bank
      end

      def init_round
        stock_round
      end

      def operating_order
        minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
        minors + majors
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
          Step::BuyTrain,
        ], round_num: round_num)
      end

      def setup
        @bidding_token_per_player = init_bidding_token
        setup_companies
        setup_bidboxes
      end

      def sorted_corporations
        @corporations.select { |c| c.floated? && c.type == :major }
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
        @companies.select { |c| c.id[0] == 'M' && (c.owner.nil? || c.owner == @bank) }.map.first(4)
      end

      def bidbox_concessions
        @companies.select { |c| c.id[0] == 'C' && (c.owner.nil? || c.owner == @bank) }.map.first(3)
      end

      def bidbox_privates
        @companies.select { |c| c.id[0] == 'P' && (c.owner.nil? || c.owner == @bank) }.map.first(3)
      end

      def init_bidding_token
        self.class::BIDDING_TOKENS[@players.size.to_s]
      end

      def setup_bidboxes
        # Set the owner to bank for the companies up for auction this stockround
        bidbox_minors.map do |minor_company|
          minor_company.owner = @bank
        end

        bidbox_concessions.map do |concessions|
          concessions.owner = @bank
        end

        bidbox_privates.map do |private_company|
          private_company.owner = @bank
        end
      end

      private

      def setup_companies
        # Randomize from preset seed to get same order
        @companies.sort_by! { rand }

        minors = @companies.select { |c| c.id[0] == 'M' }
        concessions = @companies.select { |c| c.id[0] == 'C' }
        privates = @companies.select { |c| c.id[0] == 'P' }

        # Always set the P1, C1 and M24 in the first biddingbox
        m24 = minors.find { |c| !c.nil? && c.id == 'M24' }
        minors.delete(m24)
        minors.unshift(m24)

        c1 = concessions.find { |c| !c.nil? && c.id == 'C1' }
        concessions.delete(c1)
        concessions.unshift(c1)

        p1 = privates.find { |c| !c.nil? && c.id == 'P1' }
        privates.delete(p1)
        privates.unshift(p1)

        # Clear and add the companies in the correct randomize order sorted by type
        @companies.clear
        @companies.concat(minors)
        @companies.concat(concessions)
        @companies.concat(privates)

        # Set the min bid on the Concessions and Minors
        @companies.each do |c|
          case c.id[0]
          when 'C', 'M'
            c.min_price = c.value
          else
            c.min_price = 0
          end
          c.max_price = 1000
        end
      end
    end
  end
end
