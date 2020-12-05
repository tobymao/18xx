# rubocop:disable Lint/RedundantCopDisableDirective, Layout/LineLength
# frozen_string_literal: true

require_relative '../config/game/g_1870'
require_relative 'base'
require_relative '../g_1870/stock_market'

module Engine
  module Game
    class G1870 < Base
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
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::BuySellParShares,
          Step::G1870::PriceProtection,
        ])
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::Exchange,
          Step::DiscardTrain,
          Step::G1870::BuyCompany,
          Step::Track,
          Step::Token,
          Step::Route,
          Step::G1870::Dividend,
          Step::BuyTrain,
          [Step::G1870::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def init_stock_market
        Engine::G1870::StockMarket.new(self.class::MARKET, self.class::CERT_LIMIT_TYPES,
                                       multiple_buy_types: self.class::MULTIPLE_BUY_TYPES)
      end

      def setup
        river_company.max_price = river_company.value
      end

      def event_companies_buyable!
        river_company.max_price = 2 * river_company.value
      end

      def event_remove_tokens!
        removals = Hash.new { |h, k| h[k] = {} }

        @corporations.each do |corp|
          corp.assignments.dup.each do |company, _|
            if ASSIGNMENT_TOKENS.keys.any?(company)
              removals[company][:corporation] = corp.name
              corp.remove_assignment!(company)
            end
          end
        end

        @hexes.each do |hex|
          hex.assignments.dup.each do |company, _|
            if ASSIGNMENT_TOKENS.keys.any?(company)
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

      def purchasable_companies(entity = nil)
        return super unless @phase.name == '1'
        return [river_company] if [mp_corporation, ssw_corporation].any?(entity)

        []
      end

      def corporation_opts
        { can_hold_above_max: true }
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

        revenue
      end

      def sell_shares_and_change_price(bundle, _allow_president_change: true, _swap: nil)
        @round.sell_queue << bundle

        @share_pool.sell_shares(bundle)
      end

      def legal_tile_rotation?(_entity, hex, tile)
        return true unless river_company.abilities(:blocks_division)

        (tile.exits & hex.tile.borders.select { |b| b.type == :water }.map(&:edge)).empty? &&
          hex.tile.divisions.all? do |division|
            tile.paths.all? do |path|
              (path.exits - division.inner).empty? || (path.exits - division.outer).empty?
            end
          end
      end

      def upgrades_to?(from, to, _special = false)
        return to.name == '170' if from.color == :green && P_HEXES.any?(from.hex.name)

        return to.name == '171K' if from.color == :brown && from.hex.name == 'B11'
        return to.name == '172L' if from.color == :brown && from.hex.name == 'C18'

        super(from, to, false, to.cities.size.positive? && %i[yellow green].any?(to.color))
      end

      def border_impassable?(border)
        border.type == :water
      end
    end
  end
end

# rubocop:enable Lint/RedundantCopDisableDirective, Layout/LineLength
