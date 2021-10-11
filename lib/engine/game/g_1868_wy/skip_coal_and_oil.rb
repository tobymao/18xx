# frozen_string_literal: true

module Engine
  module Game
    module G1868WY
      module SkipCoalAndOil
        def log_skip(entity)
          super unless entity.minor?
        end
      end
    end
  end
end
