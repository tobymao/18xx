# frozen_string_literal: true

module Engine
  module Game
    module G1861
      module SkipForNational
        def actions(entity)
          return [] if entity.corporation? && entity.type == :national

          super
        end

        def log_skip(entity)
          super if entity.type != :national
        end
      end
    end
  end
end
