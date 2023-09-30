# frozen_string_literal: true

require_relative '../../../step/buy_company'

module Engine
  module Game
    module G1844
      module Step
        class BuyCompany < Engine::Step::BuyCompany
          def actions(entity)
            return [] if entity.corporation? && entity.type == :'pre-sbb'

            super
          end
        end
      end
    end
  end
end
