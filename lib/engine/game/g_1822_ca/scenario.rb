# frozen_string_literal: true

require_relative '../g_1822/scenario'

module Engine
  module Game
    module G1822CA
      module Scenario
        include G1822::Scenario

        CERT_LIMIT = { 2 => 27, 3 => 17, 4 => 13, 5 => 10 }.freeze
        STARTING_CASH = { 2 => 750, 3 => 500, 4 => 375, 5 => 300 }.freeze

        UPGRADE_COST_L_TO_2_PHASE_2 = 70

        GAME_END_ON_NOTHING_SOLD_IN_SR1 = false

        MARKET = [
          %w[5y 10y 15y 20y 25y 30y 35y 40y 45y 50p 60xp 70xp 80xp 90xp 100xp 110 120 135 150 165 180 200 220
             245 270 300 330 360 400 450 500e 550e 600e],
        ].freeze

        TRAINS = [
          {
            name: 'L',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 14,
            price: 50,
            rusts_on: '3',
            variants: [
              {
                name: '2',
                distance: 2,
                price: 120,
                rusts_on: '4',
                available_on: '1',
              },
            ],
          },
          {
            name: '3',
            distance: 3,
            num: 6,
            price: 200,
            rusts_on: '6',
          },
          {
            name: '4',
            distance: 4,
            num: 4,
            price: 300,
            rusts_on: '7',
          },
          {
            name: '5',
            distance: 5,
            num: 2,
            price: 500,
            events: [
              {
                'type' => 'close_concessions',
              },
            ],
          },
          {
            name: '6',
            distance: 6,
            num: 3,
            price: 600,
            events: [
              {
                'type' => 'full_capitalisation',
              },
            ],
          },
          {
            name: '7',
            distance: 7,
            num: 20,
            price: 750,
            variants: [
              {
                name: 'E',
                distance: 99,
                multiplier: 2,
                price: 1000,
              },
            ],
            events: [
              {
                'type' => 'phase_revenue',
              },
            ],
          },
          {
            name: '2P',
            distance: 2,
            num: 2,
            price: 0,
          },
          {
            name: 'LP',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 1,
                'visit' => 1,
              },
              {
                'nodes' => ['town'],
                'pay' => 1,
                'visit' => 1,
              },
            ],
            num: 1,
            price: 0,
          },
          {
            name: '5P',
            distance: 5,
            num: 1,
            price: 500,
          },
          {
            name: 'P',
            distance: [
              {
                'nodes' => ['city'],
                'pay' => 99,
                'visit' => 99,
              },
              {
                'nodes' => ['town'],
                'pay' => 99,
                'visit' => 99,
              },
            ],
            num: 2,
            price: 0,
          },
        ].freeze

        def discountable_trains_for(corporation)
          discount_info = []

          upgrade_cost = if @phase.name.to_i < 2
                           self.class::UPGRADE_COST_L_TO_2
                         else
                           self.class::UPGRADE_COST_L_TO_2_PHASE_2
                         end
          corporation.trains.select { |t| t.name == 'L' }.each do |train|
            discount_info << [train, train, '2', upgrade_cost]
          end
          discount_info
        end

        def starting_companies
          return self.class::STARTING_COMPANIES_TWOPLAYER if @players.size == 2

          self.class::STARTING_COMPANIES
        end

        def init_corporations(stock_market)
          game_corporations.map do |corporation|
            next unless self.class::STARTING_CORPORATIONS.include?(corporation[:sym])

            opts = self.class::STARTING_CORPORATIONS_OVERRIDE[corporation[:sym]] || {}
            Corporation.new(
              min_price: stock_market.par_prices.map(&:price).min,
              capitalization: self.class::CAPITALIZATION,
              **corporation.merge(opts),
            )
          end.compact
        end

        def block_detroit_duluth; end
        def event_open_detroit_duluth!; end

        def init_companies(players)
          game_companies.map do |company|
            next if players.size < (company[:min_players] || 0)
            next unless starting_companies.include?(company[:sym])

            opts = self.class::STARTING_COMPANIES_OVERRIDE[company[:sym]] || {}
            company = init_private_company_color(company)
            Company.new(**company.merge(opts))
          end.compact
        end

        # no extra OR in set when bank breaks
        def game_end_set_final_turn!(reason, after); end
      end
    end
  end
end
