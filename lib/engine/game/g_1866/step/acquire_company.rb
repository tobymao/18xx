# frozen_string_literal: true

require_relative '../../../step/acquire_company'

module Engine
  module Game
    module G1866
      module Step
        class AcquireCompany < Engine::Step::AcquireCompany
          def skip!
            pass!
          end
        end
      end
    end
  end
end
