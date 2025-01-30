# frozen_string_literal: true

module Engine
  module Game
    module G1837
      module Step
        module SkipReceivership
          def actions(entity)
            return [] if entity.receivership?

            super
          end

          def skip!
            super unless current_entity.receivership?
          end
        end
      end
    end
  end
end
