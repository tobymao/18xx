# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G1860
      class Token < Token
        def actions(entity)
          return [] if entity.receivership?

          super
        end
      end
    end
  end
end
