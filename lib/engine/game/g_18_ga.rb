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
        'can_buy_companies_from_other_players' => ['Interplayer Company Buy', 'Companies can be bought between players']
      ).merge(
        Step::SingleDepotTrainBuyBeforePhase4::STATUS_TEXT
      ).freeze

      STANDARD_YELLOW_CITY_TILES = %w[5 6 57].freeze
      STANDARD_GREEN_CITY_TILES = %w[14 15].freeze

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
        neutral.owner = @bank

        neutral.tokens.each { |token| token.type = :neutral }

        city_by_id('E1-0-0').place_token(neutral, neutral.next_token)
        city_by_id('J4-0-0').place_token(neutral, neutral.next_token)

        # Remember specific tiles for upgrades check later
        @green_aug_tile ||= @tiles.find { |t| t.name == '453a' }
        @green_s_tile ||= @tiles.find { |t| t.name == '454a' }
        @brown_b_tile ||= @tiles.find { |t| t.name == '457a' }
        @brown_m_tile ||= @tiles.find { |t| t.name == '458a' }

        # The last 2 train will be used as free train for a private
        # Store it in neutral corporation in the meantime
        @free_2_train = train_by_id('2-5')
        @free_2_train.buyable = false
        neutral.buy_train(@free_2_train, :free)
      end

      def operating_round(round_num)
        Round::Operating.new(self, [
          Step::Bankrupt,
          Step::DiscardTrain,
          Step::SpecialToken,
          Step::G18GA::BuyCompany,
          Step::HomeToken,
          Step::SpecialTrack,
          Step::Track,
          Step::G18GA::Token,
          Step::Route,
          Step::Dividend,
          Step::SingleDepotTrainBuyBeforePhase4,
          [Step::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def upgrades_to?(from, to, special = false)
        # Augusta (D10) use standard tiles for yellow, and special tile for green
        return to.name == '453a' if from.color == :yellow && from.hex.name == 'D10'

        # Savannah (G13) use standard tiles for yellow, and special tile for green
        return to.name == '454a' if from.color == :yellow && from.hex.name == 'G13'

        # Brunswick (I11) use standard tiles for yellow/green, and special tile for brown
        return to.name == '457a' if from.color == :green && from.hex.name == 'I11'

        # Macon (F6) use standard tiles for yellow/green, and special tile for brown
        return to.name == '458a' if from.color == :green && from.hex.name == 'F6'

        super
      end

      def all_potential_upgrades(tile, tile_manifest: false)
        upgrades = super

        return upgrades unless tile_manifest

        upgrades |= [@green_aug_tile] if @green_aug_tile && STANDARD_YELLOW_CITY_TILES.include?(tile.name)
        upgrades |= [@green_s_tile] if @green_s_tile && STANDARD_YELLOW_CITY_TILES.include?(tile.name)
        upgrades |= [@brown_b_tile] if @brown_b_tile && STANDARD_GREEN_CITY_TILES.include?(tile.name)
        upgrades |= [@brown_m_tile] if @brown_m_tile && STANDARD_GREEN_CITY_TILES.include?(tile.name)

        upgrades
      end

      def add_free_two_train(corporation)
        @free_2_train.buyable = true
        corporation.buy_train(@free_2_train, :free)
        @free_2_train.buyable = false
        @log << "#{corporation.name} receives a bonus non sellable 2 train"
      end
    end
  end
end
