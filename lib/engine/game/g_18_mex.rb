# frozen_string_literal: true

require_relative '../config/game/g_18_mex'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'
require_relative 'revenue_4d'
module Engine
  module Game
    class G18MEX < Base
      load_from_json(Config::Game::G18MEX::JSON)
      AXES = { x: :number, y: :letter }.freeze

      GAME_LOCATION = 'Mexico'
      GAME_RULES_URL = 'https://secure.deepthoughtgames.com/games/18MEX/rules.pdf'
      GAME_DESIGNER = 'Mark Derrick'
      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

      STANDARD_GREEN_CITY_TILES = %w[14 15 619].freeze

      EVENTS_TEXT = Base::EVENTS_TEXT.merge(
        'minors_closed' => ['Minors closed', 'Minors closed, NdM available'],
        'ndm_merger' => ['NdM merger', 'NdM merger']
      ).freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        Step::SingleDepotTrainBuy::STATUS_TEXT
      ).merge(
        'ndm_available' => ['NdM available', 'NdM shares available during stock round'],
      ).freeze

      def p2_company
        @p2_company ||= company_by_id('KCMO')
      end

      include CompanyPrice50To150Percent
      include Revenue4D

      def setup
        setup_company_price_50_to_150_percent

        @minors.each do |minor|
          train = @depot.upcoming[0]
          train.buyable = false
          minor.cash = 100
          minor.buy_train(train)
          hex = hex_by_id(minor.coordinates)
          hex.tile.cities[0].place_token(minor, minor.next_token)
        end

        @brown_g_tile ||= @tiles.find { |t| t.name == '480' }
        @gray_tile ||= @tiles.find { |t| t.name == '455' }
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::BuyCompany,
          Step::HomeToken,
          Step::G18MEX::SpecialTrack,
          Step::G18MEX::Track,
          Step::Token,
          Step::Route,
          Step::G18MEX::Dividend,
          Step::SingleDepotTrainBuy,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def stock_round
        Round::Stock.new(self, [
          Step::DiscardTrain,
          Step::G18MEX::BuySellParShares,
        ])
      end

      def new_stock_round
        @minors.each do |minor|
          matching_company = @companies.find { |company| company.sym == minor.name }
          minor.owner = matching_company.owner
        end if @turn == 1
        super
      end

      def revenue_for(route, stops)
        adjust_revenue_for_4d_train(route, stops, super)
      end

      def event_minors_closed!
        @log << 'Now minors should close. Not implemented yet!'
      end

      def event_ndm_merger!
        @log << 'Now NdM should offer to merge other corporation. Not implemented yet!'
      end

      def upgrades_to?(from, to, special = false)
        # Copper Canyon cannot be upgraded
        return false if from.name == '470'

        # Guadalajara (O8) can only be upgraded to #480 in brown, and #455 in gray
        return to.name == '480' if from.color == :green && from.hex.name == 'O8'
        return to.name == '455' if from.color == :brown && from.hex.name == 'O8'

        super
      end

      def all_potential_upgrades(tile, tile_manifest: false)
        # Copper Canyon cannot be upgraded
        return [] if tile.name == '470'

        upgrades = super

        return upgrades unless tile_manifest

        # Tile manifest for standard green cities should show G tile as an option
        upgrades |= [@brown_g_tile] if @brown_g_tile && STANDARD_GREEN_CITY_TILES.include?(tile.name)

        # Tile manifest for Guadalajara brown (the G tile) should gray tile as an option
        upgrades |= [@gray_tile] if @gray_tile && tile.name == '480'

        upgrades
      end
    end
  end
end
