# frozen_string_literal: true

require_relative '../config/game/g_1861'
require_relative 'g_1867'

module Engine
  module Game
    class G1861 < G1867
      DEV_STAGE = :prealpha

      load_from_json(Config::Game::G1861::JSON)

      def self.title
        '1861'
      end

      def unstarted_corporation_summary
        summary, _corps = super
        [summary, [@national]]
      end

      def nationalization_loan_movement(corporation)
        corporation.loans.each do
          stock_market.move_left(corporation)
        end
      end

      def maximum_loans(entity)
        entity.type == :national ? 100 : super
      end

      def operating_order
        minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
        minors + majors + [@national]
      end

      def operating_round(round_num)
        @national.owner = priority_deal_player
        @log << "#{@national.name} run by #{@national.owner.name}, as they have priority deal"
        calculate_interest
        Round::G1861::Operating.new(self, [
          Step::G1867::MajorTrainless,
          Step::G1861::BuyCompany,
          Step::G1867::RedeemShares,
          Step::G1861::Track,
          Step::G1861::Token,
          Step::Route,
          Step::G1861::Dividend,
          # The blocking buy company needs to be before loan operations
          [Step::G1861::BuyCompany, blocks: true],
          Step::G1867::LoanOperations,
          Step::DiscardTrain,
          Step::G1861::BuyTrain,
          [Step::G1861::BuyCompany, blocks: true],
        ], round_num: round_num)
      end

      def or_round_finished; end
    end
  end
end
