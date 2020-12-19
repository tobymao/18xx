# frozen_string_literal: true

require_relative '../assign'

module Engine
  module Step
    module G1849
      class Assign < Assign
        def process_assign(action)
          super
          action.entity.close!
        end
      end
    end
  end
end
