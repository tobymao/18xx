# frozen_string_literal: true

require_relative '../config/game/g_1849'
require_relative 'base'
require_relative '../g_1849/corporation'

module Engine
  module Game
    class G1849 < Base
      register_colors(black: '#000000',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#ff0000',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a',
                      goldenrod: '#f9b231')

      load_from_json(Config::Game::G1849::JSON)
      AXES = { x: :number, y: :letter }.freeze

      DEV_STAGE = :prealpha

      GAME_LOCATION = 'Sicily'
      GAME_RULES_URL = 'https://boardgamegeek.com/filepage/206628/1849-rules'
      GAME_DESIGNER = 'Federico Vellani'
      GAME_PUBLISHER = :all_aboard_games
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1849'

      # TODO: game ends immediately after a company that has reached 377 finishes operating
      GAME_END_CHECK = { bank: :full_or }.freeze

      # TODO: player leaves game or takes loan
      BANKRUPTCY_ALLOWED = false

      CLOSED_CORP_RESERVATIONS = :remain

      EBUY_OTHER_VALUE = false
      HOME_TOKEN_TIMING = :float
      SELL_AFTER = :operate
      SELL_BUY_ORDER = :sell_buy
      SELL_MOVEMENT = :down_per_10
      POOL_SHARE_DROP = :one

      # TODO: companies must be sold in operating order
      # SELL_ORDER = :market_value

      MARKET_TEXT = Base::MARKET_TEXT.merge(phase_limited: 'Can only enter during phase 16').freeze
      STOCKMARKET_COLORS = {
        par: :yellow,
        endgame: :orange,
        close: :purple,
        phase_limited: :blue,
      }.freeze

      AFG_HEXES = %w[C1 H8 M9 M11 B14].freeze

      def setup
        @corporations.sort_by! { rand }
        # TODO: Add variant for 4 player 5 corp game
        remove_corp_and_trains if @players.size == 3
        @corporations.each { |c| c.next_to_par = false }
        @corporations[0].next_to_par = true
      end

      def remove_corp_and_trains
        removed = @corporations.pop
        @log << "Removed #{removed.name}"
        # TODO: Remove 6H, 8H, 16H
      end

      def after_par(corporation)
        super
        corporation.next_to_par = false
        index = @corporations.index(corporation)

        @corporations[index + 1].next_to_par = true unless index == @corporations.length - 1
      end

      def home_token_locations(corporation)
        raise NotImplementedError unless corporation.name == 'AFG'

        AFG_HEXES.map { |coord| hex_by_id(coord) }.select do |hex|
          hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) }
        end
      end

      def init_corporations(stock_market)
        min_price = stock_market.par_prices.map(&:price).min

        self.class::CORPORATIONS.map do |corporation|
          Engine::G1849::Corporation.new(
            min_price: min_price,
            capitalization: self.class::CAPITALIZATION,
            **corporation.merge(corporation_opts),
          )
        end
      end

      def close_corporation(corporation, quiet: false)
        super
        corporation = reset_corporation(corporation)
        @corporations.push(corporation)
        corporation.closed_recently = true
        corporation.next_to_par = true if @corporations[@corporations.length - 2].floated?
      end

      def new_stock_round
        @corporations.each { |c| c.closed_recently = false }
        super
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::HomeToken,
          Step::BuySellParShares,
        ])
      end

      def event_earthquake!
        @log << '-- Event: Messina Earthquake --'
        # Remove tile from Messina

        # Remove from game tokens on Messina

        # If Garibaldi's only token removed, close Garibaldi

        # Messina cannot be upgraded until after next stock round
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
                               Step::Bankrupt,
                               Step::Exchange,
                               Step::DiscardTrain,
                               Step::SpecialTrack,
                               Step::BuyCompany,
                               Step::G1849::Track,
                               Step::Token,
                               Step::Route,
                               Step::Dividend,
                               Step::BuyTrain,
                               [Step::BuyCompany, blocks: true],
                             ], round_num: round_num)
      end

      def new_track(old_tile, new_tile)
        # Assume path retention checked elsewhere
        old_track = old_tile.paths.map(&:track)
        added_track = new_tile.paths.map(&:track)
        old_track.each { |t| added_track.slice!(added_track.index(t) || added_track.length) }
        if added_track.include?(:dual)
          :dual
        else
          added_track.include?(:broad) ? :broad : :narrow
        end
      end

      def tile_cost(tile, _hex, entity, new_tile: nil)
        return 0 if tile.upgrades.empty?

        upgrade = tile.upgrades[0]
        track = new_track(tile, new_tile)
        case track
        when :dual
          upgrade.cost
        when :narrow
          @log << "#{entity.name} pays 1/4 cost for narrow gauge track"
          upgrade.cost / 4
        when :broad
          ability = entity.all_abilities.find { |a| a.type == :tile_discount }
          discount = ability ? upgrade.cost / 2 : 0
          if discount.positive?
            @log << "#{entity.name} receives a discount of "\
                    "#{format_currency(discount)} from "\
                    "#{ability.owner.name}"
          end
          upgrade.cost - discount
        end
      end
    end
  end
end
