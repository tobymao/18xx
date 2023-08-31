# frozen_string_literal: true

require_relative '../g_1817/game'
require_relative 'meta'
require_relative 'round/operating'
require_relative 'entities'
require_relative 'map'

module Engine
  module Game
    module G1817WO
      class Game < G1817::Game
        include_meta(G1817WO::Meta)
        include Entities
        include Map

        attr_reader :new_zealand_city

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 99_999

        CERT_LIMIT = { 2 => 16, 3 => 13, 4 => 11, 5 => 9 }.freeze

        STARTING_CASH = { 2 => 330, 3 => 240, 4 => 195, 5 => 168 }.freeze

        CAPITALIZATION = :incremental

        MUST_SELL_IN_BLOCKS = false

        MARKET = [
          %w[0l
             0a
             0a
             0a
             40
             45
             50p
             55s
             60p
             65p
             70s
             80p
             90p
             100p
             110p
             120s
             135p
             150p
             165p
             180p
             200p
             220
             245
             270
             300
             330
             360
             400
             440
             490
             540
             600],
           ].freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [2],
          },
          {
            name: '2+',
            on: '2+',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 2,
            corporation_sizes: [2],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [2, 5],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            corporation_sizes: [5],
          },
          {
            name: '5',
            on: '5',
            train_limit: 3,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [5, 10],
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
          {
            name: '7',
            on: '7',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: ['no_new_shorts'],
            operating_rounds: 2,
            corporation_sizes: [10],
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 48 },
                  { name: '2+', distance: 2, price: 100, obsolete_on: '4', num: 2 },
                  {
                    name: '3',
                    distance: 3,
                    price: 250,
                    rusts_on: '6',
                    num: 7,
                    events: [{ 'type' => 'nieuw_zeeland_available' }],
                  },
                  { name: '4', distance: 4, price: 400, rusts_on: '8', num: 5 },
                  { name: '5', distance: 5, price: 600, num: 3 },
                  { name: '6', distance: 6, price: 750, num: 2 },
                  { name: '7', distance: 7, price: 900, num: 2 },
                  {
                    name: '8',
                    distance: 8,
                    price: 1100,
                    num: 32,
                    events: [{ 'type' => 'signal_end_game' }],
                  }].freeze

        SEED_MONEY = 100
        EVENTS_TEXT = G1817::Game::EVENTS_TEXT.merge('nieuw_zeeland_available' => ['Nieuw Zealand opens for new IPOs'])
        MAX_LOAN = 65
        LOANS_PER_INCREMENT = 3

        def setup_preround
          super
          @pittsburgh_private = @companies.find { |c| c.id == 'PSM' }
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

        def tokenable_location_exists?
          # Using hexes > tile > cities because simply using cities also gets cities
          # that are on tiles not yet laid.
          hexes.any? { |h| h.tile.cities.any? { |c| c.tokens.count(&:nil?).positive? } }
        end

        def can_place_second_token(corporation)
          return false if !tokenable_location_exists? || !corp_has_new_zealand?(corporation)

          # Does the corp have a second token already?
          corporation.tokens[1] && !corporation.tokens[1].city
        end

        # This must be idempotent.
        def place_second_token(corporation)
          return unless can_place_second_token(corporation)

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

          G1817WO::Round::Operating.new(self, [
            G1817::Step::Bankrupt,
            G1817::Step::CashCrisis,
            G1817::Step::Loan,
            G1817::Step::SpecialTrack,
            G1817::Step::Assign,
            G1817::Step::Track,
            Engine::Step::Token,
            Engine::Step::Route,
            G1817::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1817::Step::BuyTrain,
          ], round_num: round_num)
        end

        def stock_round
          close_bank_shorts
          @interest_fixed = nil

          G1817::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            G1817WO::Step::HomeToken,
            G1817WO::Step::BuySellParShares,
          ])
        end
      end
    end
  end
end
