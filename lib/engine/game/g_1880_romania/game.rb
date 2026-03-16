# frozen_string_literal: true

require_relative 'meta'
require_relative '../g_1880/game'
require_relative 'map'
require_relative 'entities'

module Engine
  module Game
    module G1880Romania
      class Game < G1880::Game
        include_meta(G1880Romania::Meta)
        include G1880Romania::Map
        include G1880Romania::Entities

        CURRENCY_FORMAT_STR = 'L%s'

        CERT_LIMIT = { 3 => 20, 4 => 16, 5 => 14, 6 => 12 }.freeze

        STARTING_CASH = { 3 => 600, 4 => 480, 5 => 400, 6 => 340 }.freeze

        PHASES = [{ name: 'A1', train_limit: 4, tiles: [:yellow] },
                  {
                    name: 'A2',
                    on: '2+2',
                    train_limit: 4,
                    tiles: %i[yellow],
                  },
                  {
                    name: 'B1',
                    on: '3',
                    train_limit: 4,
                    tiles: %i[yellow green],
                  },
                  {
                    name: 'B2',
                    on: '3+3',
                    train_limit: 3,
                    tiles: %i[yellow green],
                  },
                  {
                    name: 'C1',
                    on: '4',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                  },
                  {
                    name: 'C2',
                    on: '4+4',
                    train_limit: 3,
                    tiles: %i[yellow green brown],
                  },
                  {
                    name: 'D1',
                    on: '6',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                  },
                  {
                    name: 'D2',
                    on: '6E',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                  },
                  {
                    name: 'D3',
                    on: '8',
                    train_limit: 2,
                    tiles: %i[yellow green brown gray],
                  }].freeze

        TRAINS = [{ name: '2', distance: 2, price: 100, rusts_on: '4', num: 10 },
                  {
                    name: '2+2',
                    distance: [{ 'nodes' => ['town'], 'pay' => 2, 'visit' => 2 },
                               { 'nodes' => %w[city offboard town], 'pay' => 2, 'visit' => 2 }],
                    price: 180,
                    rusts_on: '4+4',
                    num: 5,
                    events: [{ 'type' => 'open_borders' }],
                  },
                  {
                    name: '3',
                    distance: 3,
                    price: 180,
                    rusts_on: '6',
                    num: 5,
                    events: [{ 'type' => 'float_30' },
                             { 'type' => 'permit_b' },
                             { 'type' => 'all_shares_available' },
                             { 'type' => 'receive_capital' },
                             { 'type' => 'can_buy_trains' }],
                  },
                  {
                    name: '3+3',
                    distance: [{ 'nodes' => ['town'], 'pay' => 3, 'visit' => 3 },
                               { 'nodes' => %w[city offboard town], 'pay' => 3, 'visit' => 3 }],
                    price: 300,
                    rusts_on: '6E',
                    num: 5,
                    events: [{ 'type' => 'communist_takeover' },
                             { 'type' => 'remove_borders' }],
                  },
                  {
                    name: '4',
                    distance: 4,
                    price: 300,
                    rusts_on: '8',
                    num: 5,
                    events: [{ 'type' => 'float_40' },
                             { 'type' => 'permit_c' }],
                  },
                  {
                    name: '4+4',
                    distance: [{ 'nodes' => ['town'], 'pay' => 4, 'visit' => 4 },
                               { 'nodes' => %w[city offboard town], 'pay' => 4, 'visit' => 4 }],
                    price: 600,
                    num: 5,
                    events: [{ 'type' => 'stock_exchange_reopens' }],
                  },
                  {
                    name: '6',
                    distance: 6,
                    price: 600,
                    num: 5,
                    events: [{ 'type' => 'float_60' },
                             { 'type' => 'token_cost_doubled' },
                             { 'type' => 'permit_d' }],
                  },
                  {
                    name: '6E',
                    distance: [{ 'nodes' => %w[city offboard town], 'pay' => 6, 'visit' => 99 }],
                    price: 700,
                    num: 5,
                    events: [{ 'type' => 'signal_end_game', 'when' => 5 }],
                  },
                  {
                    name: '8',
                    distance: 8,
                    price: 800,
                    num: 2,
                  },
                  {
                    name: '8E',
                    distance: [{ 'nodes' => %w[city offboard town], 'pay' => 8, 'visit' => 99 }],
                    price: 900,
                    num: 2,
                  },
                  { name: '2P', distance: 2, price: 250, num: 10, available_on: 'C2' }].freeze

        EVENTS_TEXT = G1880::Game::EVENTS_TEXT.merge(
          'signal_end_game' => ['Signal End Game', 'Game ends 3 ORs after purchase of last 6E train']
        ).freeze

        def stock_round
          G1880Romania::Round::Stock.new(self, [
            Engine::Step::Exchange,
            G1880::Step::BuySellParShares,
          ])
        end

        def operating_round(round_num)
          G1880::Round::Operating.new(self, [
            Engine::Step::HomeToken,
            Engine::Step::Exchange,
            Engine::Step::DiscardTrain,
            G1880Romania::Step::Assign,
            G1880Romania::Step::Track,
            G1880::Step::Token,
            G1880::Step::Route,
            G1880::Step::Dividend,
            G1880Romania::Step::BuyTrain,
            G1880::Step::CheckFIConnection,
          ], round_num: round_num)
        end

        def event_open_borders!
          @log << "-- Event: Borders opened, owner of #{p2.name} still receives payment for built crossings --"

          self.class::BORDERS.each do |coord, edges|
            hex = hex_by_id(coord)
            next unless hex

            hex.tile.modify_borders(edges, type: :province)
          end

          clear_graph
        end

        def event_remove_borders!
          @log << '-- Event: Borders removed --'

          self.class::BORDERS.each do |coord, edges|
            hex = hex_by_id(coord)
            next unless hex

            hex.tile.modify_borders(edges, type: nil)
          end
        end

        def handle_province_crossing_income(hex, entity_or_entities)
          entity = Array(entity_or_entities).first
          return unless entity&.corporation?

          crossings = hex.tile.borders.select { |b| %i[province impassable].include?(b.type) }
          return if crossings.empty?

          income = 20 * crossings.size
          bank.spend(income, p2.owner)

          @log << "#{p2.owner.name} receives #{format_currency(income)} for province crossing"
        end

        def remove_border_calculate_cost!(tile, entity_or_entities, spender)
          total_cost, border_types = super

          @province_crossings ||= {}
          @province_crossings[tile.hex] = border_types.count { |t| %i[province impassable].include?(t) }

          [total_cost, border_types]
        end

        def revenue_for(route, stops)
          revenue = super
          revenue += 10 if danube_port_bonus?(route)

          revenue
        end

        def revenue_str(route)
          str = super
          str += " + Danube Port Bonus (#{format_currency(10)})" if danube_port_bonus?(route)
          str
        end

        def p2
          @p2 ||= company_by_id('P2')
        end

        def danube_port
          @danube_port ||= company_by_id('P4')
        end

        def danube_port_bonus?(route)
          route.stops.any? { |stop| stop.hex.assigned?(danube_port.id) } && route.corporation.owner == danube_port.owner
        end

        # This game's Electroputere S.A. private company's forced train exchange is identical to the forced exchange for the
        # Rocket of China in 1880, so we can reuse that logic here rather than recoding the whole thing.
        def forced_exchange_rocket?
          phase.name == 'B2' && !rocket.closed?
        end
      end
    end
  end
end
