# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative 'entities'
require_relative 'map'
require_relative 'meta'

module Engine
  module Game
    module G1822MRS
      class Game < G1822::Game
        include_meta(G1822MRS::Meta)
        include Entities
        include Map

        BIDDING_BOX_START_MINOR = 'M24'
        BIDDING_BOX_START_MINOR_ADV = 'M14'

        CERT_LIMIT = { 2 => 27, 3 => 18, 4 => 14, 5 => 11, 6 => 9, 7 => 8 }.freeze

        EXCHANGE_TOKENS = {
          'LNWR' => 4,
          'GWR' => 3,
          'LBSCR' => 3,
          'SECR' => 3,
          'MR' => 3,
          'LYR' => 3,
          'SWR' => 3,
        }.freeze

        STARTING_CASH = { 2 => 750, 3 => 500, 4 => 375, 5 => 300, 6 => 250, 7 => 215 }.freeze

        MARKET = [
          ['', '', '', '', '', '', '', '', '', '', '', '', '',
           '330', '360', '400', '450', '500e', '550e', '600e'],
          ['', '', '', '', '', '', '', '', '',
           '200', '220', '245', '270', '300', '330', '360', '400', '450', '500e', '550e'],
          %w[70 80 90 100 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450 500e],
          %w[60 70 80 90 100xp 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450],
          %w[50 60 70 80 90xp 100 110 120 135 150 165 180 200 220 245 270 300 330],
          %w[45y 50 60 70 80xp 90 100 110 120 135 150 165 180 200 220 245],
          %w[40y 45y 50 60 70xp 80 90 100 110 120 135 150 165 180],
          %w[35y 40y 45y 50 60xp 70 80 90 100 110 120 135],
          %w[30y 35y 40y 45y 50p 60 70 80 90 100],
          %w[25y 30y 35y 40y 45y 50 60 70 80],
          %w[20y 25y 30y 35y 40y 45y 50y 60y],
          %w[15y 20y 25y 30y 35y 40y 45y],
          %w[10y 15y 20y 25y 30y 35y],
          %w[5y 10y 15y 20y 25y],
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
            num: 7,
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
            name: 'P+',
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

        UPGRADE_COST_L_TO_2_PHASE_2 = 70

        def bidbox_start_minor
          return self.class::BIDDING_BOX_START_MINOR_ADV if optional_advanced?

          self.class::BIDDING_BOX_START_MINOR
        end

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
          return self.class::STARTING_COMPANIES_ADVANCED if optional_advanced?
          return self.class::STARTING_COMPANIES_TWOPLAYER if @players.size == 2

          self.class::STARTING_COMPANIES
        end

        def optional_advanced?
          @optional_rules&.include?(:advanced)
        end
      end
    end
  end
end
