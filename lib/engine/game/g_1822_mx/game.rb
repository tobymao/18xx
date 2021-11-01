# frozen_string_literal: true

require_relative '../g_1822/game'
require_relative 'meta'
require_relative 'map'

module Engine
  module Game
    module G1822MX
      class Game < G1822::Game
        include_meta(G1822MX::Meta)
        include G1822MX::Entities
        include G1822MX::Map

        BIDDING_BOX_START_MINOR = 'M24'
        BIDDING_BOX_START_MINOR_ADV = 'M14'

        CERT_LIMIT = { 2 => 27, 3 => 18, 4 => 14, 5 => 11, 6 => 9, 7 => 8 }.freeze

        EXCHANGE_TOKENS = {
          'FCM' => 3,
          'MC' => 3,
          'CHP' => 3,
          'FNM' => 3,
          'MIR' => 3,
          'FCP' => 3,
          'IRM' => 3,
        }.freeze

        STARTING_CASH = { 2 => 750, 3 => 500, 4 => 375, 5 => 300, 6 => 250, 7 => 215 }.freeze

        STARTING_COMPANIES = %w[P1 P2 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15 P16 P18
                                C1 C2 C3 C4 C5 C6 C7 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                M16 M17 M18 M19 M20 M21 M22 M23 M24].freeze

        STARTING_COMPANIES_ADVANCED = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12
                                         C1 C2 C3 C4 C5 C6 C7 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                         M16 M17 M18 M19 M20 M21 M24].freeze

        STARTING_COMPANIES_TWOPLAYER = %w[P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12
                                          C1 C2 C3 C4 C5 C6 C7 M7 M8 M9 M10 M11 M12 M13 M14 M15
                                          M16 M17 M18 M19 M20 M21 M24].freeze

        STARTING_CORPORATIONS = %w[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
                                   FCM MC CHP FNM MIR FCP IRM].freeze

        MARKET = [
          ['', '', '', '', '', '', '', '', '', '', '', '', '',
           '330', '360', '400', '450', '500e', '550e', '600e'],
          ['', '', '', '', '', '', '', '', '',
           '200', '220', '245', '270', '300', '330', '360', '400', '450', '500e', '550e'],
          %w[70 80 90 100 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450 500e],
          %w[60 70 80 90 100px 110 120 135 150 165 180 200 220 245 270 300 330 360 400 450],
          %w[50 60 70 80 90px 100 110 120 135 150 165 180 200 220 245 270 300 330],
          %w[45y 50 60 70 80px 90 100 110 120 135 150 165 180 200 220 245],
          %w[40y 45y 50 60 70px 80 90 100 110 120 135 150 165 180],
          %w[35y 40y 45y 50 60px 70 80 90 100 110 120 135],
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
