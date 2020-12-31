# frozen_string_literal: true

require_relative '../dividend'
require_relative '../minor_half_pay'

module Engine
  module Step
    module G1828
      class Dividend < Dividend
        include MinorHalfPay

        def dividends_for_entity(entity, holder, per_share)
          # Include payout for treasury share
          entity.system? ? ((holder.num_shares_of(entity) + 1) * per_share).ceil : super
        end
      end
    end
  end
end
