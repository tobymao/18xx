# frozen_string_literal: true

require_relative '../g_1822_pnw/game'
require_relative '../g_1822/scenario'
require_relative 'meta'
require_relative 'trains'

module Engine
  module Game
    module G1822PnwSrs
      class Game < G1822PNW::Game
        include_meta(G1822PnwSrs::Meta)
        include G1822::Scenario
        include Trains

        STARTING_COMPANIES = %w[P1 P2 P3 P5 P7 P9 P10 P11 P14 P15 P16 P18
                                M6 M7 M8 M9 M10 M11 M12 M13 M14 M15 M16 M17 M18 M19 M20 M21 MB MC].freeze

        STARTING_CORPORATIONS = %w[6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
                                   CMPS NP ORNC SPS SWW ].freeze

        EXCHANGE_TOKENS = {
          'CMPS' => 3,
          'SWW' => 3,
          'SPS' => 3,
          'ORNC' => 3,
          'NP' => 3,
        }.freeze

        CERT_LIMIT = { 2 => 18, 3 => 14 }.freeze
        STARTING_CASH = { 2 => 750, 3 => 500 }.freeze
        BIDDING_TOKENS = { '2' => 6, '3' => 5 }.freeze

        STATUS_TEXT = G1822PNW::Game::STATUS_TEXT.merge(
          'l_upgrade' => ['$70 L-train upgrades',
                          'The cost to upgrade an L-train to a 2-train is reduced from $80 to $70.']
        )
        UPGRADE_COST_L_TO_2_PHASE_2 = 70

        MARKET = [
          %w[40 50p 55x 60x 65x 70x 75x 80x 90x 100x
             110 120 135 150 165 180 200 220 245 270 300 330 360
             400 450 500e 550e 600e],
        ].freeze

        GAME_END_ON_NOTHING_SOLD_IN_SR1 = false

        def setup_companies
          setup_associated_minors
          @companies.sort_by! { rand }

          privates = @companies.select { |c| c.id[0] == self.class::COMPANY_PRIVATE_PREFIX }
          private_1 = privates.find { |c| c.id == 'P1' }
          privates.delete(private_1)
          privates.unshift(private_1)

          minors = @companies.select { |c| c.id[0] == self.class::COMPANY_MINOR_PREFIX }
          minor_6, minors = minors.partition { |c| c.id == 'M6' }
          minors_assoc, minors = minors.partition { |c| @minor_associations.key?(corp_id_from_company_id(c.id)) }

          # Clear and add the companies in the correct randomize order sorted by type
          @companies.clear
          @companies.concat(minor_6)
          stack_1 = (minors_assoc[0..1] + minors[0..3]).sort_by! { rand }
          @companies.concat(stack_1)
          stack_2 = (minors_assoc[2..3] + minors[4..7]).sort_by! { rand }
          @companies.concat(stack_2)
          stack_3 = (minors_assoc[4..4] + minors[8..11]).sort_by! { rand }
          @companies.concat(stack_3)
          @companies.concat(privates)

          # Setup company abilities
          @company_trains = {}
          @company_trains['P1'] = find_and_remove_train_by_id('5P-0')
          @company_trains['P2'] = find_and_remove_train_by_id('2P-0', buyable: false)
          @company_trains['P3'] = find_and_remove_train_by_id('LP-0', buyable: false)
          @company_trains['P5'] = find_and_remove_train_by_id('P-0', buyable: false)
        end

        def setup_game_specific
          super

          # remove CPR and GNR logos from their home hexes
          hex_by_id('A8').tile.icons.clear
          hex_by_id('D23').tile.icons.clear
        end
      end
    end
  end
end
