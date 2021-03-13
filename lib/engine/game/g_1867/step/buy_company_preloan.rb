# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G1867
      module Step
        class BuyCompanyPreloan < Engine::Step::BuyCompany
          def auto_actions(entity)
            # If the entity has no loans then passing here makes no difference
            [Engine::Action::Pass.new(entity)] if entity.loans.empty?
          end
        end
      end
    end
  end
end
