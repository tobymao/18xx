# frozen_string_literal: true

require_relative '../config/game/g_1882'
require_relative 'base'

module Engine
  module Game
    class G1882 < Base
      register_colors(green: '#237333',
                      gray: '#9a9a9d',
                      red: '#d81e3e',
                      blue: '#0189d1',
                      yellow: '#FFF500',
                      brown: '#7b352a')

      DEV_STAGE = :production

      AXES = { x: :number, y: :letter }.freeze
      CORPORATIONS_WITHOUT_NEUTRAL = %w[CPR CN].freeze

      load_from_json(Config::Game::G1882::JSON)

      GAME_LOCATION = 'Assiniboia, Canada'
      GAME_RULES_URL = 'https://boardgamegeek.com/thread/2389239/article/35386441#35386441'
      GAME_DESIGNER = 'Marc Voyer'
      GAME_PUBLISHER = Publisher::INFO[:all_aboard_games]
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1882'

      SELL_BUY_ORDER = :sell_buy_sell
      TRACK_RESTRICTION = :permissive
      DISCARDED_TRAINS = :remove
      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'nwr' => ['North West Rebellion',
                  'Remove all yellow tiles from NWR-marked hexes. Station markers remain']
      ).freeze

      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_round, bank: :full_or }.freeze
      # Two lays or one upgrade, second tile costs 20
      TILE_LAYS = [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false, cost: 20 }].freeze

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::G1882::HomeToken,
          Step::G1882::BuySellParShares,
        ])
      end

      def new_auction_round
        Round::Auction.new(self, [
          Step::CompanyPendingPar,
          Step::G1882::WaterfallAuction,
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::BuyCompany,
          Step::DiscardTrain,
          Step::HomeToken,
          Step::G1882::SpecialNWR,
          Step::G1882::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::BuyTrain,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def home_token_locations(corporation)
        raise NotImplementedError unless corporation.name == 'SC'

        # SC, find all locations with neutral or no token
        cn_corp = corporations.find { |x| x.name == 'CN' }
        hexes = @hexes.dup
        hexes.select do |hex|
          hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) || city.tokened_by?(cn_corp) }
        end
      end

      def add_extra_train_when_sc_pars(corporation)
        first = depot.upcoming.first
        train = @sc_reserve_trains.find { |t| t.name == first.name }
        @sc_company = nil
        return unless train

        # Move events other than NWR rebellion earlier.
        train.events, first.events = first.events.partition { |e| e['type'] != 'nwr' }

        @log << "#{corporation.name} adds an extra #{train.name} train to the depot"
        @depot.unshift_train(train)
      end

      def init_train_handler
        depot = super

        # Grab the reserve trains that SC can add
        trains = %w[3 4 5 6]

        @sc_reserve_trains = []
        trains.each do |train_name|
          train = depot.upcoming.select { |t| t.name == train_name }.last
          @sc_reserve_trains << train
          depot.upcoming.delete(train)
        end

        # Due to SC adding an extra train this isn't quite a phase change, so the event needs to be tied to a train.
        nwr_train = trains[rand % trains.size]
        @log << "NWR Rebellion occurs on purchase of the currently first #{nwr_train} train"
        train = depot.upcoming.find { |t| t.name == nwr_train }
        train.events << { 'type' => 'nwr' }

        depot
      end

      def setup
        cp = @companies.find { |company| company.name == 'Canadian Pacific' }
        cp.add_ability(Ability::Close.new(
          type: :close,
          when: :train,
          corporation: cp.abilities(:share).share.corporation.name,
        ))
      end

      def init_company_abilities
        @companies.each do |company|
          next unless (ability = company.abilities(:exchange))

          next unless ability.from.include?(:par)

          corporation = corporation_by_id(ability.corporation)
          corporation.par_via_exchange = company
          @sc_company = company
        end
        super
      end

      def init_corporations(stock_market)
        min_price = stock_market.par_prices.map(&:price).min

        corporations = self.class::CORPORATIONS.map do |corporation|
          corporation[:needs_token_to_par] = true if corporation[:sym] == 'CN'
          Corporation.new(
            min_price: min_price,
            capitalization: self.class::CAPITALIZATION,
            **corporation,
          )
        end

        # CN's tokens use a neutral logo, but as layed become owned by cn but don't block other players
        cn_corp = corporations.find { |x| x.name == 'CN' }
        corporations.each do |x|
          unless CORPORATIONS_WITHOUT_NEUTRAL.include?(x.name)
            x.tokens << Token.new(cn_corp, price: 0, logo: '/logos/1882/neutral.svg', type: :neutral)
          end
        end
        corporations
      end

      def event_nwr!
        @log << '-- Event: North West Rebellion! --'
        name = 'NWR'
        @hexes.each do |hex|
          next unless hex.tile.icons.any? { |icon| icon.name == name }

          next unless hex.tile.color == :yellow
          next unless hex.tile != hex.original_tile

          @log << "Rebellion destroys tile #{hex.name}"
          old_tile = hex.tile
          hex.lay_downgrade(hex.original_tile)
          tiles << old_tile
        end

        # Some companies might no longer have valid routes
        @graph.clear_graph_for_all
      end

      def revenue_for(route)
        revenue = super

        stops = route.stops
        # East offboards I1, B2
        east = stops.find { |stop| %w[I1 B2].include?(stop.hex.name) }
        # Hudson B12
        west = stops.find { |stop| stop.hex.name == 'B12' }
        revenue += 100 if east && west

        revenue
      end

      def action_processed(_action)
        return unless @sc_company
        return if !@sc_company.closed? && !@sc_company&.owner&.corporation?

        @log << 'Saskatchewan Central can no longer be converted to a public corporation'
        @corporations.reject! { |c| c.id == 'SC' }
        @sc_company = nil
      end
    end
  end
end
