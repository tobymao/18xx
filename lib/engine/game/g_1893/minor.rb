# frozen_string_literal: true

require_relative '../../minor'

module Engine
  module Game
    module G1893
      class Minor < Engine::Minor

        def percent_of(_corp)
          0
        end

        def shares_of(_corp)
          []
        end

        def holding_ok?(_entity, _amount)
          false
        end

        def ipoed
          false
        end

        def <=>(other)
          1
        end
      end
    end
  end
end
