# frozen_string_literal: true

require_relative '../config/game/g_1822'
require_relative '../g_1822/depot'
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

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'can_buy_trains' => ['Can buy trains', 'Can buy trains from other corporations']
      ).freeze

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

      def can_run_route?(entity)
        entity.trains.any? { |t| t.name == 'L' } || super
      end

      def check_overlap(routes)
        super

        # Check local train not use the same token more then one time
        local_token_hex = []
        routes.each do |route|
          local_token_hex << route.head[:left].hex.id if route.train.local? && !route.connections.empty?
        end

        local_token_hex.group_by(&:itself).each do |k, v|
          raise GameError, "Local train can only use the token on #{k[0]} once." if v.size > 1
        end
      end

      def entity_can_use_company?(_entity, company)
        # Setting bidding companies owner to bank, make sure the abilities dont show for theese
        company.owner != @bank
      end

      def format_currency(val)
        return super if (val % 1).zero?

        format('£%.1<val>f', val: val)
      end

      def train_help(runnable_trains)
        return [] if (l_trains = runnable_trains.select { |t| t.name == 'L' }).empty?

        corporation = l_trains.first.owner
        ["L (local) trains run in a city which has a #{corporation.name} token.",
         'They can additionally run to a single small station, but are not required to do so. '\
         'They can thus be considered 1 (+1) trains.',
         'Only one L train may operate on each station token.']
      end

      def init_round
        stock_round
      end

      # This is need to handle the upgrade from L -> 2 train.
      def init_train_handler
        trains = self.class::TRAINS.flat_map do |train|
          (train[:num] || num_trains(train)).times.map do |index|
            Train.new(**train, index: index)
          end
        end

        Engine::G1822::Depot.new(trains, self)
      end

      # TODO: Make include with 1861, 1867
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
          Step::G1822::Dividend,
          Step::DiscardTrain,
          Step::G1822::BuyTrain,
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
        @companies.select { |c| c.id[0] == 'M' && (!c.owner || c.owner == @bank) }.first(4)
      end

      def bidbox_concessions
        @companies.select { |c| c.id[0] == 'C' && (!c.owner || c.owner == @bank) }.first(3)
      end

      def bidbox_privates
        @companies.select { |c| c.id[0] == 'P' && (!c.owner || c.owner == @bank) }.first(3)
      end

      def init_bidding_token
        self.class::BIDDING_TOKENS[@players.size.to_s]
      end

      def setup_bidboxes
        # Set the owner to bank for the companies up for auction this stockround
        bidbox_minors.each do |minor|
          minor.owner = @bank
        end

        bidbox_concessions.each do |concessions|
          concessions.owner = @bank
        end

        bidbox_privates.each do |company|
          company.owner = @bank
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
        m24 = minors.find { |c| c.id == 'M24' }
        minors.delete(m24)
        minors.unshift(m24)

        c1 = concessions.find { |c| c.id == 'C1' }
        concessions.delete(c1)
        concessions.unshift(c1)

        p1 = privates.find { |c| c.id == 'P1' }
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
