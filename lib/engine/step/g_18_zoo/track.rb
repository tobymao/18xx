# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18ZOO
      class Track < Track
        def lay_tile(action, _extra_cost: 0, _entity: nil, _spender: nil)
          super

          if action.hex.tile.color == :yellow
            @log << "and now do other thing" #TODO: Debug log, will be removed later
          end
        end
      end
    end
  end
end
