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
            return unless entity == @game.london_corporation

            li = @game.companies.find { |c| c.sym == 'P4' }
            return unless li

            @log << 'London Investment closes'
            li.close!
          end
        end
      end
    end
  end
end
