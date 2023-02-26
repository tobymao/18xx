# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../base'
require_relative '../../game_error'
require_relative '../g_1856/game'

module Engine
  module Game
    module G1836Jr56
      class Game < G1856::Game
        include_meta(G1836Jr56::Meta)
        include Entities
        include Map

        CURRENCY_FORMAT_STR = '%s F'

        BANK_CASH = 6000

        CERT_LIMIT = { 2 => 20, 3 => 13, 4 => 10 }.freeze
        def cert_limit(_player = nil)
          # cert limit isn't dynamic in 1836jr56
          CERT_LIMIT[@players.size]
        end

        STARTING_CASH = { 2 => 450, 3 => 300, 4 => 225 }.freeze

        PHASES = [
          {
            name: '2',
            train_limit: 4,
            tiles: [:yellow],
            status: %w[escrow facing_2],
            operating_rounds: 1,
          },
          {
            name: "2'",
            on: "2'",
            train_limit: 4,
            tiles: [:yellow],
            status: %w[escrow facing_3],
            operating_rounds: 1,
          },
          {
            name: '3',
            on: '3',
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[escrow facing_3 can_buy_companies],
          },
          {
            name: "3'",
            on: "3'",
            train_limit: 4,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[escrow facing_4 can_buy_companies],
          },
          {
            name: '4',
            on: '4',
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[escrow facing_4 can_buy_companies],
          },
          {
            name: "4'",
            on: "4'",
            train_limit: 3,
            tiles: %i[yellow green],
            operating_rounds: 2,
            status: %w[incremental facing_5 can_buy_companies],
          },
          {
            name: '5',
            on: '5',
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[incremental facing_5],
            operating_rounds: 3,
          },
          {
            name: "5'",
            on: "5'",
            train_limit: 2,
            tiles: %i[yellow green brown],
            status: %w[fullcap facing_6],
            operating_rounds: 3,
          },
          {
            name: '6',
            on: '6',
            train_limit: 2,
            tiles: %i[yellow green brown gray],
            status: %w[fullcap facing_6 upgradable_towns no_loans],
            operating_rounds: 3,
          },
          {
            name: '8',
            on: '8',
            train_limit: 2,
            tiles: %i[yellow green brown gray black],
            status: %w[fullcap facing_6 upgradable_towns no_loans],
            operating_rounds: 3,
          },
        ].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 4 },
                  { name: "2'", distance: 2, price: 100, rusts_on: '4', num: 1 },
                  { name: '3', distance: 3, price: 225, rusts_on: '6', num: 3 },
                  { name: "3'", distance: 3, price: 225, rusts_on: '6', num: 1 },
                  { name: '4', distance: 4, price: 350, rusts_on: '8', num: 2 },
                  {
                    name: "4'",
                    distance: 4,
                    price: 350,
                    rusts_on: '8',
                    num: 1,
                    events: [{ 'type' => 'no_more_escrow_corps' }],
                  },
                  {
                    name: '5',
                    distance: 5,
                    price: 550,
                    num: 1,
                    events: [{ 'type' => 'close_companies' }],
                  },
                  {
                    name: "5'",
                    distance: 5,
                    price: 550,
                    num: 1,
                    events: [{ 'type' => 'no_more_incremental_corps' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 700,
                    num: 2,
                    events: [{ 'type' => 'nationalization' }, { 'type' => 'remove_tokens' }],
                  },
                  {
                    name: '8',
                    distance: 8,
                    price: 1000,
                    num: 5,
                    available_on: '6',
                    discount: { '4' => 350, "4'" => 350, '5' => 350, "5'" => 350, '6' => 350 },
                  }].freeze

        ASSIGNMENT_TOKENS = {
          'RdP' => '/icons/1846/sc_token.svg',
        }.freeze
        PORT_HEXES = %w[A9 B8 B10 D6 E5 E11 F4 F10 G7 H2 H4 H6 H10 I3 I9 J6 J8 K11].freeze

        HAMILTON_HEX = 'A1' # Don't use; the future_label renders nicely in 1836jr56
        DESTINATIONS = {
          'NBDS' => 'E5',
          'HSM' => 'E11',
          'NFL' => 'D6',
          'B' => 'H10',
          'Nord' => 'I9',
          'GCL' => 'K13',
        }.freeze

        SELL_BUY_ORDER = :sell_buy_sell
        TILE_RESERVATION_BLOCKS_OTHERS = :always
        def national
          @national ||= corporation_by_id('MESS')
        end

        def port
          @port ||= company_by_id('RdP')
        end

        def company_bought(company, entity) end

        def tunnel
          raise GameError, "'tunnel' Should not be used"
        end

        def bridge
          raise GameError, "'bridge' Should not be used"
        end

        def wsrc
          raise GameError, "'wsrc' Should not be used"
        end

        def setup
          @straight_city ||= @all_tiles.find { |t| t.name == '57' }
          @sharp_city ||= @all_tiles.find { |t| t.name == '5' }
          @gentle_city ||= @all_tiles.find { |t| t.name == '6' }

          @straight_track ||= @all_tiles.find { |t| t.name == '9' }
          @sharp_track ||= @all_tiles.find { |t| t.name == '7' }
          @gentle_track ||= @all_tiles.find { |t| t.name == '8' }

          @x_city ||= @all_tiles.find { |t| t.name == '14' }
          @k_city ||= @all_tiles.find { |t| t.name == '15' }

          @brown_london ||= @all_tiles.find { |t| t.name == '126' }
          @brown_barrie ||= @all_tiles.find { |t| t.name == '127' }

          @gray_hamilton ||= @all_tiles.find { |t| t.name == '123' }

          @post_nationalization = false
          @nationalization_train_discard_trigger = false
          @national_formed = false

          @pre_national_percent_by_player = {}
          @pre_national_market_percent = 0

          @pre_national_market_prices = {}
          @nationalized_corps = []

          @bankrupted = false

          @destination_statuses = {}

          # Is the president of the national a "false" president?
          # A false president gets the presidency with only one share; in this case the president gets
          # the full president's certificate but is obligated to buy up to the full presidency in the
          # following SR unless a different player becomes rightfully president during share exchange
          # It is impossible for someone who didn't become president in
          # exchange (1 share tops) to steal the presidency in the SR because
          # they'd have to buy 2 shares in one action which is a no-no
          # nil: Presidency not awarded yet at all
          # not-nl: 1-share false presidency has been awarded to the player (value of var)
          @false_national_president = nil

          # CGR flags
          @national_ever_owned_permanent = false

          # Corp -> Borrowed Train
          @borrowed_trains = {}
          create_destinations(DESTINATIONS)
          national.add_ability(self.class::NATIONAL_IMMOBILE_SHARE_PRICE_ABILITY)
          national.add_ability(self.class::NATIONAL_FORCED_WITHHOLD_ABILITY)
        end

        def stock_round
          G1856::Round::Stock.new(self, [
            Engine::Step::DiscardTrain,
            Engine::Step::Exchange,
            Engine::Step::SpecialTrack,
            G1856::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G1856::Round::Operating.new(self, [
            G1856::Step::Bankrupt,
            G1856::Step::CashCrisis,
            # No exchanges.
            G1856::Step::Assign,
            G1856::Step::Loan,
            Engine::Step::SpecialTrack,
            Engine::Step::SpecialToken,
            Engine::Step::BuyCompany,
            Engine::Step::HomeToken,

            # Nationalization!!
            G1856::Step::NationalizationPayoff,
            G1856::Step::RemoveTokens,
            G1856::Step::NationalizationDiscardTrains,
            G1836Jr56::Step::Track,
            G1856::Step::Escrow,
            G1856::Step::Token,
            G1856::Step::BorrowTrain,
            Engine::Step::Route,
            # Interest - See Loan
            G1856::Step::Dividend,
            Engine::Step::DiscardTrain,
            G1836Jr56::Step::BuyTrain,
            # Repay Loans - See Loan
            [G1856::Step::BuyCompany, { blocks: true }],
          ], round_num: round_num)
        end

        def event_close_companies!
          @log << '-- Event: Private companies close --'
          @companies.each do |company|
            if (ability = abilities(company, :close, on_phase: 'any')) && (ability.on_phase == 'never' ||
                      @phase.phases.any? { |phase| ability.on_phase == phase[:name] })
              next
            end

            company.close!
          end
        end

        def icon_path(corp)
          super if corp == national

          "../logos/1836_jr/#{corp}"
        end

        def revenue_for(route, stops)
          revenue = super # port private is counted in super

          port_stop = stops.find { |stop| stop.groups.include?('port') }
          # Port offboards
          if port_stop
            raise GameError, "#{port_stop.tile.location_name} must contain 2 other stops" if stops.size < 3

            per_token = port_stop.route_revenue(route.phase, route.train)
            revenue -= per_token # It's already been counted, so remove

            revenue += stops.sum do |stop|
              next per_token if stop.city? && stop.tokened_by?(route.train.owner)

              0
            end
          end

          revenue
        end
      end
    end
  end
end
