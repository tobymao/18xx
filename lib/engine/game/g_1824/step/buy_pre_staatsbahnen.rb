# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G1824
      module Step
        class BuyPreStaatsbahnen < Engine::Step::BuyCompany
          ACTIONS_NO_PASS = %w[buy_company].freeze

          def actions(_entity)
            ACTIONS_NO_PASS
          end

          def can_buy_company?(_entity)
            true
          end

          def blocks?
            false
          end

          def active?
            true
          end
        end
      end
    end
  end
end
