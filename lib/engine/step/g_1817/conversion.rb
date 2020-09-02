# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1817
      class Conversion < Base
        def actions(_entity)
          ['convert']
        end

        def description
          'Convert Corporation'
        end
      end
    end
  end
end
