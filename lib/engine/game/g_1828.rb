# frozen_string_literal: true

require_relative '../config/game/g_1828'
require_relative 'base'
require_relative '../g_1828/stock_market'

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

      MULTIPLE_BUY_TYPES = %i[unlimited].freeze

      MUST_BID_INCREMENT_MULTIPLE = true
      MIN_BID_INCREMENT = 5

      HOME_TOKEN_TIMING = :operate

      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_round, custom: :one_more_full_or_set }.freeze

      SELL_BUY_ORDER = :sell_buy_sell

      NEXT_SR_PLAYER_ORDER = :first_to_pass

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'green_par' => ['Green phase pars',
                        '$86 and $94 par prices are now available'],
        'blue_par' => ['Blue phase pars',
                       '$105 par price is now available'],
        'brown_par' => ['Brown phase pars',
                        '$120 par price is now available'],
        'remove_corporations' => ['Non-parred corporations removed',
                                  'All non-parred corporations are removed. Blocking tokens placed in home stations']
      ).freeze

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
        Round::G1828::Stock.new(self, [
          Step::DiscardTrain,
          Step::Exchange,
          Step::SpecialTrack,
          Step::G1828::BuySellParShares,
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::DiscardTrain,
          Step::SpecialTrack,
          Step::G1828::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::G1828::Dividend,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def setup
        setup_minors
        remove_extra_private_companies
        remove_extra_trains
      end

      def init_stock_market
        sm = Engine::G1828::StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_TYPES,
                                            multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
        sm.enable_par_price(67)
        sm.enable_par_price(71)
        sm.enable_par_price(79)

        sm
      end

      EXTRA_TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false, cost: 40 }].freeze
      EXTRA_TILE_LAY_CORPS = %w[B&M NYH].freeze

      def tile_lays(entity)
        return self.class::EXTRA_TILE_LAYS if EXTRA_TILE_LAY_CORPS.find(entity.id)

        super
      end

      def corporation_opts
        { can_hold_above_max: true }
      end

      def init_round_finished
        @players.rotate!(@round.entity_index)
      end

      def event_green_par!
        @log << "-- Event: #{EVENTS_TEXT['green_par'][1]} --"
        stock_market.enable_par_price(86)
        stock_market.enable_par_price(94)
      end

      def event_blue_par!
        @log << "-- Event: #{EVENTS_TEXT['blue_par'][1]} --"
        stock_market.enable_par_price(105)
      end

      def event_brown_par!
        @log << "-- Event: #{EVENTS_TEXT['brown_par'][1]} --"
        stock_market.enable_par_price(120)
      end

      def event_close_companies!
        super

        @minors.dup.each { |minor| remove_minor!(minor) }
      end

      def event_remove_corporations!
        @log << "-- Event: #{EVENTS_TEXT['remove_corporations'][1]}. --"
        @corporations.reject(&:ipoed).each do |corporation|
          place_home_token(corporation)
          place_second_home_token(corporation) if corporation.name == 'ERIE'
          @log << "Removing #{corporation.name}"
          @corporations.delete(corporation)
        end
      end

      def custom_end_game_reached?
        @phase.current[:name] == 'Purple'
      end

      def remove_minor!(minor)
        @round.force_next_entity! if @round.current_entity == minor
        minor.spend(minor.cash, @bank) if minor.cash.positive?
        @minors.delete(minor)
      end

      private

      def setup_minors
        @minors.each do |minor|
          train = @depot.upcoming[0]
          train.buyable = false
          minor.buy_train(train, :free)
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[0].place_token(minor, minor.next_token, free: true)
        end
      end

      def remove_extra_private_companies
        to_remove = companies.find_all { |company| company.value == 250 }
                             .sort_by { rand }
                             .take(7 - @players.size)
        to_remove.each do |company|
          company.close!
          @round.active_step.companies.delete(company)
          @log << "Removing #{company.name}"
        end
      end

      def remove_extra_trains
        return unless @players.size < 5

        to_remove = @depot.trains.reverse.find { |train| train.name == '5' }
        @depot.remove_train(to_remove)
        @log << "Removing #{to_remove.name} train"
      end

      def place_second_home_token(corporation)
        token = corporation.find_token_by_type
        hex = hex_by_id(corporation.coordinates)
        @log << "#{corporation.name} places a second token on #{hex.name}"
        hex.tile.cities[1].place_token(corporation, token, check_tokenable: false)
      end
    end
  end
end
