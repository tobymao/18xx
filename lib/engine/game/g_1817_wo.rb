# frozen_string_literal: true

require_relative 'g_1817'
require_relative '../config/game/g_1817_wo'

module Engine
  module Game
    class G1817WO < G1817
      attr_reader :new_zealand_city

      load_from_json(Config::Game::G1817WO::JSON)

      DEV_STAGE = :production
      GAME_PUBLISHER = nil
      PITTSBURGH_PRIVATE_NAME = 'PSM'
      PITTSBURGH_PRIVATE_HEX = 'I6'

      GAME_LOCATION = 'Earth.'
      SEED_MONEY = 100
      GAME_INFO_URL = 'https://github.com/tobymao/18xx/wiki/1817WO'
      GAME_RULES_URL = {
        '1817WO' => 'https://docs.google.com/document/d/1g9QnttpJa8yOCOTnfPaU9hfAZFFzg-rAs_WGy9T38J0/',
        '1817 Rules' => 'https://drive.google.com/file/d/0B1SWz2pNe2eAbnI4NVhpQXV4V0k/view',
      }.freeze
      GAME_DESIGNER = 'Mark Voyer & Brennan Sheremeto'
      EVENTS_TEXT = G1817::EVENTS_TEXT.merge('nieuw_zeeland_available' => ['Nieuw Zealand opens for new IPOs'])
      MAX_LOAN = 65
      LOANS_PER_INCREMENT = 3

      def self.title
        '1817WO'
      end

      def setup
        super
        @new_zealand_city = hexes.find { |hex| hex.location_name == 'Nieuw Zeeland' }.tile.cities[0]
        # Put an 1867 style green token in the New Zealand hex
        @green_token = Token.new(nil, price: 0, logo: '/logos/1817/nz.svg', type: :neutral)
        @new_zealand_city.exchange_token(@green_token)
      end

      def event_nieuw_zeeland_available!
        # Remove the 1867-style green token from the New Zealand hex
        @log << 'Corporations can now be IPOed in Nieuw Zeeland'
        @green_token.remove!
      end

      def interest_owed(entity)
        return super unless corp_has_new_zealand?(entity)
        # A corporation with a token in new zealand gets $20 if it doesn't have any loans
        return -20 unless entity.loans.size.positive?

        # Otherwise it gets interest for one loan paid for free
        interest_owed_for_loans(entity.loans.size - 1)
      end

      def corp_has_new_zealand?(corporation)
        corporation.tokens.any? { |token| token.city == @new_zealand_city }
      end

      # This must be overridden to use 1817WO step
      def redeemable_shares(entity)
        return [] unless entity.corporation?
        return [] unless round.steps.find { |step| step.instance_of?(Step::G1817WO::BuySellParShares) }.active?

        bundles_for_corporation(share_pool, entity)
          .reject { |bundle| entity.cash < bundle.price }
      end

      def tokenable_location_exists?
        # Using hexes > tile > cities because simply using cities also gets cities
        # that are on tiles not yet laid.
        hexes.any? { |h| h.tile.cities.any? { |c| c.tokens.count(&:nil?).positive? } }
      end

      def place_second_token(corporation)
        return unless tokenable_location_exists?

        hex = hex_by_id(corporation.coordinates)

        tile = hex&.tile
        if !tile || (tile.reserved_by?(corporation) && tile.paths.any?)

          # If the tile does not have any paths at the present time, clear up the ambiguity when the tile is laid
          # otherwise the entity must choose now.
          @log << "#{corporation.name} must choose city for home token"

          hexes =
            if hex
              [hex]
            else
              home_token_locations(corporation)
            end

          @round.pending_tokens << {
            entity: corporation,
            hexes: hexes,
            token: corporation.find_token_by_type,
          }

          @round.clear_cache!
          return
        end

        cities = tile.cities
        city = cities.find { |c| c.reserved_by?(corporation) } || cities.first
        token = corporation.find_token_by_type
        return unless city.tokenable?(corporation, tokens: token)

        @log << "#{corporation.name} places a token on #{hex.name}"
        city.place_token(corporation, token)
      end

      def home_token_locations(corporation)
        # Cannot place a home token in Nieuw Zeeland until phase 3
        return super unless %w[2 2+].include?(@phase.name)

        hexes.select do |hex|
          hex.tile.cities.any? { |city| city.tokenable?(corporation, free: true) && city != new_zealand_city }
        end
      end

      # Override InterestOnLoans.pay_interest! so that we can pay "negative" interest for New Zealand
      def pay_interest!(entity)
        owed = interest_owed(entity)
        # This is here so that the log message does not get duplicated.
        if corp_has_new_zealand?(entity) && entity.loans.size.positive?
          @log << "#{entity.name}'s token in Nieuw Zeeland covers one loan's worth of interest"
        end
        return super unless owed.negative?

        # Negative interest -> corporation has New Zealand
        @log << "#{entity.name} gets $20 for having a token in Nieuw Zeeland and no loans"
        entity.spend(owed, bank, check_cash: false, check_positive: false)
        nil
      end

      def operating_round(round_num)
        @interest_fixed = nil
        @interest_fixed = interest_rate
        # Revaluate if private companies are owned by corps with trains
        @companies.each do |company|
          next unless company.owner

          abilities(company, :revenue_change, time: 'has_train') do |ability|
            company.revenue = company.owner.trains.any? ? ability.revenue : 0
          end
        end

        Round::G1817WO::Operating.new(self, [
          Step::G1817::Bankrupt,
          Step::G1817::CashCrisis,
          Step::G1817::Loan,
          Step::G1817::SpecialTrack,
          Step::G1817::Assign,
          Step::G1817::Track,
          Step::Token,
          Step::Route,
          Step::G1817::Dividend,
          Step::DiscardTrain,
          Step::G1817::BuyTrain,
        ], round_num: round_num)
      end

      def stock_round
        close_bank_shorts
        @interest_fixed = nil

        Round::G1817::Stock.new(self, [
          Step::DiscardTrain,
          Step::HomeToken,
          Step::G1817WO::BuySellParShares,
        ])
      end
    end
  end
end
