# frozen_string_literal: true

require_relative '../config/game/g_18_ga'
require_relative 'base'
require_relative 'company_price_50_to_150_percent'

module Engine
  module Game
    class G18GA < Base
      load_from_json(Config::Game::G18GA::JSON)

      DEV_STAGE = :alpha

      GAME_LOCATION = 'Georgia, USA'
      GAME_RULES_URL = 'http://www.diogenes.sacramento.ca.us/18GA_Rules_v3_26.pdf'
      GAME_DESIGNER = 'Mark Derrick'
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/18GA'
      GAME_END_CHECK = { bankrupt: :immediate, stock_market: :current_or, bank: :current_or }.freeze

      STATUS_TEXT = Base::STATUS_TEXT.merge(
        Step::SingleDepotTrainBuyBeforePhase4::STATUS_TEXT
      ).freeze

      include CompanyPrice50To150Percent

      def setup
        setup_company_price_50_to_150_percent

        # Place neutral tokens in the off board cities
        neutral = Corporation.new(
          sym: 'N',
          name: 'Neutral',
          logo: 'open_city',
          tokens: [0, 0],
        )

        neutral.tokens.each { |token| token.type = :neutral }

        city_by_id('E1-0-0').place_token(neutral, neutral.next_token)
        city_by_id('J4-0-0').place_token(neutral, neutral.next_token)

        # Remember specific tiles for upgrades check later
        @green_aug_tile ||= @tiles.find { |t| t.name == '453a' }
        @green_s_tile ||= @tiles.find { |t| t.name == '454a' }
        @brown_b_tile ||= @tiles.find { |t| t.name == '457a' }
        @brown_m_tile ||= @tiles.find { |t| t.name == '458a' }
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::G18GA::BuyCompany,
          Step::HomeToken,
          Step::G18GA::Track,
          Step::Token,
          Step::Route,
          Step::Dividend,
          Step::SingleDepotTrainBuyBeforePhase4,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      YELLOW_CITY_TILES = %w[5 6 57].freeze
      GREEN_CITY_TILES = %w[14 15].freeze

      def all_potential_upgrades(tile)
        upgrades = super

        # Need only to add more potential tiles if tile manifest (non-matching labels)
        return upgrades if tile.hex&.name != 'A1'

        upgrades << @green_aug_tile if @green_aug_tile && YELLOW_CITY_TILES.include?(tile.name)
        upgrades << @green_s_tile if @green_s_tile && YELLOW_CITY_TILES.include?(tile.name)
        upgrades << @brown_b_tile if @brown_b_tile && GREEN_CITY_TILES.include?(tile.name)
        upgrades << @brown_m_tile if @brown_m_tile && GREEN_CITY_TILES.include?(tile.name)

        upgrades
      end
    end
  end
end
