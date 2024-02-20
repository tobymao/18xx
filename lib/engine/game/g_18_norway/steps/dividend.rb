# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'
require_relative '../../../step/minor_half_pay'

module Engine
  module Game
    module G18Norway
      module Step
        class Dividend < Engine::Step::Dividend
          DIVIDEND_TYPES = %i[payout half withhold].freeze
          include Engine::Step::HalfPay

          def share_price_change(entity, revenue = 0)
            return {} if entity.minor?

            price = entity.share_price.price
            return { share_direction: :left, share_times: 1 } if revenue < price / 2

            times = 0
            times = 1 if revenue >= price
            times = 2 if revenue >= price * 2
            times = 3 if revenue >= price * 3 && price >= 165
            if times.positive?
              { share_direction: :right, share_times: times }
            else
              {}
            end
          end

          def skip!
            super

            return unless current_entity.receivership?
            return if current_entity.trains.any?
            return if current_entity.share_price.price.zero?

            @log << "#{current_entity.name} is in receivership and does not own a train."
            change_share_price(current_entity, dividend_options(current_entity)[:withhold])
          end
        end
      end
    end
  end
end
