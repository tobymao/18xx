# frozen_string_literal: true

require_relative '../g_1870/game'
require_relative 'meta'
require_relative 'map'
require_relative 'entities'
require_relative '../base'

module Engine
  module Game
    module G1850
      class Game < Game::Base
        include_meta(G1850::Meta)
        include G1850::Entities
        include G1850::Map

        attr_accessor :sell_queue, :connection_run, :reissued, :mesabi_token_counter, :mesabi_compnay_sold_or_closed

        CORPORATION_CLASS = G1850::Corporation

        CERT_LIMIT = {
          2 => { 9 => 24, 8 => 21 },
          3 => { 9 => 17, 8 => 15 },
          4 => { 9 => 14, 8 => 12 },
          5 => { 9 => 11, 8 => 9 },
          6 => { 9 => 9, 8 => 8 },
        }.freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            operating_rounds: 1,
            status: ['can_buy_companies_from_other_players'],
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies can_buy_companies_from_other_players],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[can_buy_companies can_buy_companies_from_other_players],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '10',
            on: '10',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
          {
            name: '12',
            on: '12',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [
          { name: '2', distance: 2, price: 80, rusts_on: '4', num: 6 },
          {
            name: '3',
            distance: 3,
            price: 180,
            rusts_on: '6',
            num: 6,
            events: [{ 'type' => 'companies_buyable' }],
          },
          { name: '4', distance: 4, price: 300, rusts_on: '8', num: 4 },
          {
            name: '5',
            distance: 5,
            price: 450,
            rusts_on: '12',
            num: 3,
            events: [{ 'type' => 'close_companies' }],
          },
          {
            name: '6',
            distance: 6,
            price: 630,
            num: 3,
            events: [{ 'type' => 'remove_tokens' }],
          },
          { name: '8', distance: 8, price: 800, num: 3 },
          { name: '10', distance: 10, price: 950, num: 2 },
          { name: '12', distance: 12, price: 1100, num: 12 },
        ].freeze

        TILE_LAYS = [{ lay: true, upgrade: true, cost: 0 }].freeze

        def setup
          @sell_queue = []
          @connection_run = {}
          @reissued = {}
          @recently_floated = []
          @mesabi_token_counter = 4
          # Place neutral token in Sault St. Marie
          neutral = Corporation.new(
            sym: 'N',
            name: 'Neutral',
            logo: 'open_city',
            simple_logo: 'open_city',
            tokens: [0, 0],
          )
          neutral.owner = @bank

          neutral.tokens.each { |token| token.type = :neutral }

          city_by_id('C20-0-0').place_token(neutral, neutral.next_token)

          phase_2_companies.each { |c| c.max_price = c.value }
        end

        def event_companies_buyable!
          phase_2_companies.each { |c| c.max_price = 2 * c.value }
        end

        # Everything below this line is also included in 1870's game.rb file

        CURRENCY_FORMAT_STR = '$%s'

        BANK_CASH = 12_000

        STARTING_CASH = { 2 => 1050, 3 => 700, 4 => 525, 5 => 420, 6 => 350 }.freeze

        CAPITALIZATION = :full

        MUST_SELL_IN_BLOCKS = true

        MARKET = [
          %w[64y 68 72 76 82 90 100p 110 120 140 160 180 200 225 250 275 300 325 350 375 400],
          %w[60y 64y 68 72 76 82 90p 100 110 120 140 160 180 200 225 250 275 300 325 350 375],
          %w[55y 60y 64y 68 72 76 82p 90 100 110 120 140 160 180 200 225 250i 275i 300i 325i 350i],
          %w[50o 55y 60y 64y 68 72 76p 82 90 100 110 120 140 160i 180i 200i 225i 250i 275i 300i 325i],
          %w[40b 50o 55y 60y 64 68 72p 76 82 90 100 110i 120i 140i 160i 180i],
          %w[30b 40o 50o 55y 60y 64 68p 72 76 82 90i 100i 110i],
          %w[20b 30b 40o 50o 55y 60y 64 68 72 76i 82i],
          %w[10b 20b 30b 40o 50y 55y 60y 64 68i 72i],
          %w[0c 10b 20b 30b 40o 50y 55y 60i 64i],
          %w[0c 0c 10b 20b 30b 40o 50y],
          %w[0c 0c 0c 10b 20b 30b 40o],
        ].freeze

        def operating_round(round_num)
          G1870::Round::Operating.new(self, [
            Engine::Step::Bankrupt,
            Engine::Step::Exchange,
            G1850::Step::BuyCompany,
            Engine::Step::HomeToken,
            Engine::Step::Assign,
            G1870::Step::SpecialTrack,
            G1850::Step::Track,
            G1850::Step::Token,
            Engine::Step::Route,
            G1870::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1870::Step::BuyTrain,
            [G1870::Step::BuyCompany, { blocks: true }],
            G1870::Step::PriceProtection,
          ], round_num: round_num)
        end

        def float_corporation(corporation)
          @recently_floated << corporation
          super
        end

        def tile_lays(entity)
          return super unless @recently_floated.include?(entity)

          [{ lay: true, upgrade: true }, { lay: :not_if_upgraded, upgrade: false }]
        end

        def track_action_processed(entity)
          @recently_floated.delete(entity)
        end

        def phase_2_companies
          @phase_2_companies ||= [mesabi_company, river_company]
        end

        def mesabi_company
          @mesabi_company ||= company_by_id('MRC')
        end

        def mesabi_hex
          hex_by_id('A10')
        end

        def river_company
          @river_company ||= company_by_id('MRB')
        end

        def purchasable_companies(entity = nil)
          entity ||= current_entity
          return super unless @phase.name == '2'

          phase_2_companies.select { |c| c.owner.player? }
        end

        def check_distance(route, visits, _train = nil)
          return super if visits.empty? { |v| v.hex == mesabi_hex } || route.train.owner.mesabi_token

          raise GameError, 'Corporation must own mesabi token to enter Mesabi Range'
        end

        def after_sell_company(buyer, company, _price, _seller)
          return unless company == mesabi_company

          buyer.mesabi_token = true
          @mesabi_token_counter -= 1
          @mesabi_compnay_sold_or_closed = true
          log << "#{buyer.name} receives Mesabi token. #{@mesabi_token_counter} Mesabi tokens left in the game."
          log << '-- Corporations can now buy Mesabi tokens --'
        end

        def status_array(corporation)
          return unless corporation.mesabi_token

          ['Mesabi Token']
        end
      end
    end
  end
end
