# frozen_string_literal: true

require_relative '../../../step/buy_company'
require_relative 'receivership_skip'

module Engine
  module Game
    module G1833NE
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          include ReceivershipSkip

          def can_buy_company?(entity)
            return false unless super

            @round.emergency_issued ? entity.trains.any? { |t| !t.obsolete } : true
          end
        end
      end
    end
  end
end
