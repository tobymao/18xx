# frozen_string_literal: true

require_relative '../../../step/dividend'
require_relative '../../../step/half_pay'
require_relative '../../g_1870/step/dividend'

module Engine
  module Game
    module G1832
      module Step
        class Dividend < G1870::Step::Dividend

          def payout_shares(entity, revenue)
            super
            if entity == @game.london_corporation
              @log << 'London Investment closes'
              li = @game.company_by_id('P4')
              li.close! if li
            end
            log_payout_shares(entity, revenue, per_share, receivers)
          end
        end
      end
    end
  end
end
