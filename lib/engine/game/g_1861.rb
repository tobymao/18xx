# frozen_string_literal: true

require_relative 'g_1867'

module Engine
  module Game
    class G1861 < G1867
      DEV_STAGE = :prealpha

      def self.title
        '1861'
      end

      def unstarted_corporation_summary
        summary, _corps = super
        [summary, [@cn_corporation]]
      end

      def nationalization_loan_movement(corporation)
        corporation.loans.each do
          stock_market.move_left(corporation)
        end
      end

      def event_majors_can_ipo!
        super
        @corporations << @cn_corporation
      end

      def maximum_loans(entity)
        entity.type == :national ? 100 : super
      end

      def operating_order
        minors, majors = @corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
        minors + majors + [@cn_corporation]
      end

      def operating_round(round_num)
        @cn_corporation.owner = priority_deal_player
        @log << "#{@cn_corporation.name} run by #{@cn_corporation.owner.name}, as they have priority deal"
        super
      end

      def or_round_finished; end
    end
  end
end
