# frozen_string_literal: true

require_relative '../depot'

module Engine
  module G1822
    class Depot < Depot
      UPGRADE_COST_L_TO_2 = 80

      def discountable_trains_for(corporation)
        discount_info = super

        corporation.trains.select { |t| t.name == 'L' }.each do |train|
          discount_info << [train, train, '2', UPGRADE_COST_L_TO_2]
        end
        discount_info
      end
    end
  end
end
