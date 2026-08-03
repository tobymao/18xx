# frozen_string_literal: true

require_relative 'entities'
require_relative 'map'
require_relative 'meta'
require_relative '../g_1867/game'

module Engine
  module Game
    module G1864
      class Game < G1867::Game
        include_meta(G1864::Meta)
        include Entities
        include Map

        GREEN_CORPORATIONS = %w[MB Y V TR SV E].freeze

        CERT_LIMIT = { 2 => 31, 3 => 21, 4 => 16, 5 => 13, 6 => 11 }.freeze
        STARTING_CASH = { 2 => 530, 3 => 353, 4 => 265, 5 => 212, 6 => 176 }.freeze

        # UP reserves a slot in Omaha from setup and in Cheyenne on the green upgrade.
        NATIONAL_RESERVATIONS = %w[F27 F19].freeze

        STATUS_TEXT = Base::STATUS_TEXT.merge(
          'up_operates' => ['Union Pacific operates',
                            'The Union Pacific runs the trains on its consist card and pays a full dividend'],
          'export_train' => ['Train Export',
                             'At the end of each OR the next available train is exported and removed from the game'],
        ).freeze

        PHASES = [
          { name: '2', train_limit: { minor: 2 }, tiles: [:yellow], operating_rounds: 2 },
          {
            name: '3',
            train_limit: { minor: 2, major: 4 },
            tiles: %i[yellow green],
            on: '3',
            operating_rounds: 2,
          },
          {
            name: '4',
            train_limit: { minor: 1, major: 3, national: 99 },
            tiles: %i[yellow green],
            status: %w[export_train up_operates],
            on: '4',
            operating_rounds: 2,
          },
          {
            name: '5',
            train_limit: { minor: 1, major: 3, national: 99 },
            tiles: %i[yellow green brown],
            status: %w[export_train up_operates],
            on: '5',
            operating_rounds: 2,
          },
          {
            name: '6',
            train_limit: { minor: 1, major: 2, national: 99 },
            tiles: %i[yellow green brown],
            status: %w[export_train up_operates],
            on: '6',
            operating_rounds: 2,
          },
          {
            name: '7',
            train_limit: { minor: 1, major: 2, national: 99 },
            tiles: %i[yellow green brown gray],
            status: %w[export_train up_operates],
            on: '7',
            operating_rounds: 2,
          },
          {
            name: '8',
            train_limit: { major: 2, national: 99 },
            tiles: %i[yellow green brown gray],
            status: ['up_operates'],
            on: '8',
            operating_rounds: 2,
          },
        ].freeze

        TRAINS = [
          {
            name: '2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 100,
            rusts_on: '4',
            num: 10,
          },
          {
            name: '3',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 3, 'visit' => 3 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 225,
            rusts_on: '6',
            num: 7,
            events: [{ 'type' => 'green_minors_available' }],
          },
          {
            name: '4',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 4, 'visit' => 4 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 350,
            rusts_on: '8',
            num: 4,
            events: [{ 'type' => 'majors_can_ipo' },
                     { 'type' => 'trainless_nationalization' },
                     { 'type' => 'up_operates' },
                     { 'type' => 'close_credit_mobilier' }],
          },
          {
            name: '5',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 550,
            num: 4,
            events: [{ 'type' => 'minors_cannot_start' },
                     { 'type' => 'open_tunnels' }],
          },
          {
            name: '6',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 6, 'visit' => 6 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 650,
            num: 2,
            events: [{ 'type' => 'trainless_nationalization' },
                     { 'type' => 'remove_minor_abilities' },
                     { 'type' => 'up_ipo_purchasable' },
                     { 'type' => 'enforce_ownership_limit' }],
          },
          {
            name: '7',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 7, 'visit' => 7 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 800,
            num: 2,
          },
          {
            name: '8',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 8, 'visit' => 8 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            price: 1000,
            num: 'unlimited',
            events: [{ 'type' => 'minors_nationalized' },
                     { 'type' => 'trainless_nationalization' },
                     { 'type' => 'train_trade_allowed' }],
            discount: {
              '5' => 275,
              '6' => 325,
              '7' => 400,
              '8' => 500,
              '2+2' => 300,
              '5+5E' => 750,
            },
          },
          {
            name: '2+2',
            distance: [{ 'nodes' => %w[city offboard], 'pay' => 2, 'visit' => 2 },
                       { 'nodes' => ['town'], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 600,
            num: 'unlimited',
            available_on: '8',
            discount: {
              '5' => 275,
              '6' => 325,
              '7' => 400,
              '8' => 500,
              '2+2' => 300,
              '5+5E' => 750,
            },
          },
          {
            name: '5+5E',
            distance: [{ 'nodes' => ['offboard'], 'pay' => 5, 'visit' => 5 },
                       { 'nodes' => %w[city town], 'pay' => 0, 'visit' => 99 }],
            multiplier: 2,
            price: 1500,
            num: 'unlimited',
            available_on: '8',
            discount: {
              '5' => 275,
              '6' => 325,
              '7' => 400,
              '8' => 500,
              '2+2' => 300,
              '5+5E' => 750,
            },
          },
        ].freeze

        EVENTS_TEXT = Base::EVENTS_TEXT.merge(
          'up_operates' => ['Union Pacific operates',
                            'The Union Pacific begins running trains from its consist card'],
          'close_credit_mobilier' => ['Credit Mobilier closes',
                                      'The Credit Mobilier private company closes'],
          'open_tunnels' => ['Tunnels open',
                             'The Moffat Tunnel and Lucin Cutoff through-routes become available'],
          'remove_minor_abilities' => ['Minor abilities removed',
                                       'Minor corporations lose their special abilities'],
          'up_ipo_purchasable' => ['Union Pacific shares purchasable',
                                   'Union Pacific treasury shares become available for purchase'],
          'enforce_ownership_limit' => ['Ownership limit enforced',
                                        'The certificate ownership limit is now enforced'],
        ).freeze

        attr_reader :union_pacific, :future_corporations

        def setup
          @interest = {}
          @show_majors = false
          @national_reservations = self.class::NATIONAL_RESERVATIONS.dup

          @union_pacific = @national = @corporations.find { |c| c.type == :national }
          @corporations.delete(@national)
          @national.ipoed = true
          share_price = stock_market.market.flatten.compact.find { |sp| sp.price == 80 }
          stock_market.set_par(@national, share_price)

          @corporations, @future_corporations = @corporations.partition do |corporation|
            corporation.type == :minor && !self.class::GREEN_CORPORATIONS.include?(corporation.id)
          end
        end

        def all_corporations
          @corporations + [@national]
        end

        def game_market
          self.class::COLUMN_MARKET
        end

        # 1864 has no private companies, so there is no initial auction.
        # `new_stock_round` can't be used directly: it builds its log line via
        # `round_description`, which defaults to `@round.round_num`, and `@round`
        # is not yet set the first time `init_round` runs.
        def init_round
          @log << "-- #{round_description('Stock', 1)} --"
          @round_counter += 1
          stock_round
        end

        # 1867 gives the exported train to the CN. 1864 removes it from the game.
        def or_round_finished
          return unless @phase.status.include?('export_train')

          train = @depot.upcoming.first
          @depot.export!
          @depot.forget_train(train) if train
          @log << "#{train.name} train is exported and removed from the game" if train
          post_train_buy
          game_end_check
        end

        def event_up_operates!; end

        def event_close_credit_mobilier!; end

        def event_open_tunnels!; end

        def event_remove_minor_abilities!; end

        def event_up_ipo_purchasable!; end

        def event_enforce_ownership_limit!; end

        def event_green_minors_available!
          @log << 'Green minors are now available'
          @corporations += @future_corporations
          @future_corporations = []
        end

        def init_loans
          @loan_value = 50
          Array.new(72) { |id| Loan.new(id, @loan_value) }
        end

        def add_neutral_tokens
          @green_tokens = []
        end
      end
    end
  end
end
