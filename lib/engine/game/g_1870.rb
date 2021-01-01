# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# frozen_string_literal: true

require_relative '../config/game/g_1870'
require_relative 'base'
require_relative '../g_1870/stock_market'

module Engine
  module Game
    class G1870 < Base
      attr_accessor :connection_runs

      register_colors(black: '#37383a',
                      orange: '#f48221',
                      brightGreen: '#76a042',
                      red: '#d81e3e',
                      turquoise: '#00a993',
                      blue: '#0189d1',
                      brown: '#7b352a')

      load_from_json(Config::Game::G1870::JSON)

      GAME_LOCATION = 'Mississippi, USA'
      GAME_RULES_URL = 'http://www.hexagonia.com/rules/MFG_1870.pdf'
      GAME_DESIGNER = 'Bill Dixon'
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1870'

      EBUY_PRES_SWAP = false
      EBUY_OTHER_VALUE = false

      CLOSED_CORP_TRAINS = :discarded

      CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT = true
      IPO_RESERVED_NAME = 'Treasury'

      TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }, { lay: :not_if_upgraded, upgrade: false, cost: 0 }].freeze

      STOCKMARKET_COLORS = Base::STOCKMARKET_COLORS.merge(unlimited: :green).merge(par: :white).merge(ignore_one_sale: :red).freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge('remove_tokens' => ['Remove Tokens', 'Remove private company tokens']).freeze
      MARKET_TEXT = Base::MARKET_TEXT.merge(ignore_one_sale: 'Can only enter when 2 shares sold at the same time').freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        'can_buy_companies_from_other_players' => ['Interplayer Company Buy', 'Companies can be bought between players']
      ).merge(
        'companies_buyable' => ['Companies become buyable', 'All companies may now be bought in by corporation'],
      )

      ASSIGNMENT_TOKENS = {
        'GSC' => '/icons/1870/GSC.svg',
        'GSCᶜ' => '/icons/1870/GSC_closed.svg',
        'SCC' => '/icons/1870/SCC.svg',
      }.freeze

      P_HEXES = %w[J5 B11 C18 N17].freeze

      def stock_round
        Round::G1870::Stock.new(self, [
          Step::DiscardTrain,
          Step::G1870::BuySellParShares,
          Step::G1870::PriceProtection,
        ])
      end

      def operating_round(round_num)
        Round::G1870::Operating.new(self, [
          Step::G1870::ConnectionToken,
          Step::G1870::ConnectionRoute,
          Step::G1870::ConnectionDividend,
          Step::Bankrupt,
          Step::Exchange,
          Step::DiscardTrain,
          Step::G1870::PriceProtection,
          Step::G1870::SpecialTrack,
          Step::Assign,
          Step::G1870::BuyCompany,
          Step::G1870::SpecialTrack,
          Step::G1870::Track,
          Step::Token,
          Step::Route,
          Step::G1870::Dividend,
          Step::DiscardTrain,
          Step::BuyTrain,
          [Step::G1870::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def init_stock_market
        Engine::G1870::StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_TYPES,
                                       multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
      end

      def ipo_reserved_name(_entity = nil)
        'Treasury'
      end

      def setup
        @connection_runs = {}

        river_company.max_price = river_company.value

        @corporations.each do |corporation|
          ability = abilities(corporation, :destination)
          hex = hexes.find { |h| h.name == ability.hex }

          hex.assign!(corporation)
          ability.description = "Destination: #{hex.location_name} (#{hex.name})"
        end
      end

      def event_companies_buyable!
        river_company.max_price = 2 * river_company.value
      end

      def event_remove_tokens!
        removals = Hash.new { |h, k| h[k] = {} }

        @corporations.each do |corp|
          corp.assignments.dup.each do |company, _|
            if ASSIGNMENT_TOKENS[company]
              removals[company][:corporation] = corp.name
              corp.remove_assignment!(company)
            end
          end
        end

        @hexes.each do |hex|
          hex.assignments.dup.each do |company, _|
            if ASSIGNMENT_TOKENS[company]
              removals[company][:hex] = hex.name
              hex.remove_assignment!(company)
            end
          end
        end

        removals.each do |company, removal|
          hex = removal[:hex]
          corp = removal[:corporation]
          @log << "-- Event: #{corp}'s #{company_by_id(company).name} token removed from #{hex} --"
        end
      end

      def river_company
        @river_company ||= company_by_id('MRBC')
      end

      def port_company
        @port_company ||= company_by_id('GSC')
      end

      def mp_corporation
        @mp_corporation ||= corporation_by_id('MP')
      end

      def ssw_corporation
        @ssw_corporation ||= corporation_by_id('SSW')
      end

      def river_corporations
        [ssw_corporation, mp_corporation]
      end

      def purchasable_companies(entity = nil)
        entity ||= current_entity
        return super unless @phase.name == '1'
        return [river_company] if [mp_corporation, ssw_corporation].include?(entity)

        []
      end

      def corporation_opts
        { can_hold_above_max: true }
      end

      def home_hex(corporation)
        corporation.tokens.first.city&.hex
      end

      def destination_hex(corporation)
        ability = abilities(corporation, :destination)
        hexes.find { |h| h.name == ability.hex } if ability
      end

      def assignment_tokens(assignment)
        return "/icons/#{assignment.logo_filename}" if assignment.is_a?(Engine::Corporation)

        super
      end

      def revenue_for(route, stops)
        revenue = super

        cattle = 'SCC'
        revenue += 10 if route.corporation.assigned?(cattle) && stops.any? { |stop| stop.hex.assigned?(cattle) }

        revenue += 20 if route.corporation.assigned?('GSCᶜ') && stops.any? { |stop| stop.hex.assigned?('GSCᶜ') }

        revenue += (route.corporation.assigned?('GSC') ? 20 : 10) if stops.any? { |stop| stop.hex.assigned?('GSC') }

        if stops.size >= 2
          destination = destination_hex(route.corporation)
          destination_stop = stops.values_at(0, -1).find { |s| s.hex == destination }
          if destination_stop && !destination.assigned?(route.corporation)
            revenue += destination_stop.route_revenue(route.phase, route.train)
          end
        end

        revenue
      end

      def sell_shares_and_change_price(bundle)
        @round.sell_queue << bundle

        @share_pool.sell_shares(bundle)
      end

      def legal_tile_rotation?(_entity, hex, tile)
        return true unless abilities(river_company, :blocks_partition)

        (tile.exits & hex.tile.borders.select { |b| b.type == :water }.map(&:edge)).empty? &&
          hex.tile.partitions.all? do |partition|
            tile.paths.all? do |path|
              (path.exits - partition.inner).empty? || (path.exits - partition.outer).empty?
            end
          end
      end

      def upgrades_to?(from, to, _special = false)
        return to.name == '170' if from.color == :green && P_HEXES.include?(from.hex.name)

        return to.name == '171K' if from.color == :brown && from.hex.name == 'B11'
        return to.name == '172L' if from.color == :brown && from.hex.name == 'C18'

        super(from, to, false, to.cities.any? && %i[yellow green].include?(to.color))
      end

      def border_impassable?(border)
        border.type == :water
      end

      def check_other(route)
        return unless (destination = @round.connection_runs[route.corporation])

        home = home_hex(route.corporation)
        return if route.routes.any? do |r|
          next if r.visited_stops.size < 2

          (r.visited_stops.values_at(0, -1).map(&:hex) - [home, destination]).none?
        end

        raise GameError, 'At least one train has to run from the home station to the destination'
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
