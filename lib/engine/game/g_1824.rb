# frozen_string_literal: true

require_relative '../config/game/g_1824'
require_relative 'base'
require_relative '../corporation'
module Engine
  module Game
    class G1824 < Base
      register_colors(
        gray70: '#B3B3B3',
        gray50: '#7F7F7F'
      )

      load_from_json(Config::Game::G1824::JSON)
      AXES = { x: :number, y: :letter }.freeze

      # DEV_STAGE = :alpha

      GAME_LOCATION = 'Austria-Hungary'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/188242/1824-english-rules'
      # "rules": "https://drive.google.com/file/d/1JuaUSU6fqg6fryN7l_g_r_oFa41rz3zh/view?usp=sharing"
      GAME_DESIGNER = 'Leonhard Orgler & Helmut Ohley'
      # GAME_PUBLISHER Fox in the Box
      # GAME_INFO_URL
      # "bgg": "https://boardgamegeek.com/boardgame/277030/1824-austrian-hungarian-railway-second-edition",
      GAME_END_CHECK = { bankrupt: :immediate }.freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'tokens_removed' => ['Tokens removed', 'Tokens for all private companies removed']
      ).freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'can_buy_p5' => ['Can buy P5', 'P5 can be bought']
      ).freeze

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::BuyCompany,
          Step::HomeToken,
          Step::SpecialTrack,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def init_round
        @log << '-- First Stock Round --'
        Round::G1824::FirstStock.new(self, [
          Step::G1824::BuySellParShares,
        ])
      end

      def purchasable_companies(_entity = nil)
        []
      end

      def init_corporations(stock_market)
        min_price = stock_market.par_prices.map(&:price).min

        self.class::CORPORATIONS.map do |corporation|
          Engine::Corporation.new(
            min_price: min_price,
            capitalization: self.class::CAPITALIZATION,
            **corporation.merge(corporation_opts),
          )
        end
      end

      def setup
        @coal_corporations = %w[EPP EOD MLB SPB].map { |c| corporation_by_id(c) }

        g_trains = @depot.upcoming.select { |t| t.name.end_with?('g') }
        @coal_corporations.each do |coalcorp|
          train = g_trains.shift
          coalcorp.buy_train(train, :free)
          coalcorp.spend(120, @bank, check_cash: false)
        end

        @minors.each do |minor|
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[minor.city].place_token(minor, minor.next_token)
        end
      end

      def ipo_name(entity)
        return 'Treasury' if @coal_corporations.include?(entity)

        'IPO'
      end

      def can_par?(corporation, parrer)
        super && !corporation.all_abilities.find { |a| a.type == :no_buy }
      end
    end
  end
end
