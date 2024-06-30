# frozen_string_literal: true

require_relative '../g_1822_pnw/game'
require_relative '../g_1822/scenario'
require_relative 'meta'
require_relative 'trains'
require_relative 'round/stock'

module Engine
  module Game
    module G1822PnwShort
      class Game < G1822PNW::Game
        include_meta(G1822PnwShort::Meta)
        include G1822::Scenario
        include Trains

        attr_reader :paired_assoc, :paired_unassoc

        STARTING_COMPANIES = %w[P1 P2 P3 P5 P7 P9 P10 P11 P14 P15 P16 P20
                                M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15 M16 M17 M18 M19 M20 M21 MA MB MC].freeze

        CERT_LIMIT = { 3 => 18, 4 => 14, 5 => 11 }.freeze

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

          # P1 and P20 start in first two bid boxes
          privates = @companies.select { |c| c.id[0] == self.class::COMPANY_PRIVATE_PREFIX }
          private_1 = privates.find { |c| c.id == 'P1' }
          private_20 = privates.find { |c| c.id == 'P20' }
          privates.delete(private_1)
          privates.delete(private_20)
          privates.unshift(private_20)
          privates.unshift(private_1)

          minors = @companies.select { |c| c.id[0] == self.class::COMPANY_MINOR_PREFIX }

          # pick the random pairing
          minor_pairing = [
            %w[M1 M2],
            %w[M5 M4],
            %w[M7 M9],
            %w[M8 M6],
            %w[M17 M16],
            %w[M18 M21],
            %w[M20 M10],
          ].min_by { rand }
          @paired_assoc, @paired_unassoc = minor_pairing

          # update description and starting price on the paired associated minor
          first_minor = minors.find { |c| c.id == @paired_assoc }
          last_minor = minors.find { |c| c.id == @paired_unassoc }
          first_minor.desc += " #{@paired_unassoc} is purchased along with #{@paired_assoc} for a minimum bid of $200."
          first_minor.discount = -100

          # collect rest of associated and unassociated minors
          minors.reject! { |c| minor_pairing.include?(c.id) }
          minors_assoc, minors = minors.partition { |c| @minor_associations.key?(corp_id_from_company_id(c.id)) }

          # Clear and add the companies in the correct randomize order sorted by type
          @companies.clear
          @companies.concat([first_minor])
          stack_1 = (minors_assoc[0..1] + minors[0..4]).sort_by! { rand }
          @companies.concat(stack_1)
          stack_2 = (minors_assoc[2..3] + minors[5..9]).sort_by! { rand }
          @companies.concat(stack_2)
          stack_3 = (minors_assoc[4..5] + minors[10..15]).sort_by! { rand }
          @companies.concat(stack_3)
          @companies.concat([last_minor])
          @companies.concat(privates)

          # Setup company abilities
          @company_trains = {}
          @company_trains['P1'] = find_and_remove_train_by_id('5P-0')
          @company_trains['P2'] = find_and_remove_train_by_id('2P-0', buyable: false)
          @company_trains['P3'] = find_and_remove_train_by_id('LP-0', buyable: false)
          @company_trains['P5'] = find_and_remove_train_by_id('P-0', buyable: false)
        end

        def stock_round
          G1822PnwShort::Round::Stock.new(self, [
            G1822::Step::DiscardTrain,
            G1822PNW::Step::BuySellParShares,
          ])
        end
      end
    end
  end
end
