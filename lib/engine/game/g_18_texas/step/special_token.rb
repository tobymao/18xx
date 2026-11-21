# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18Texas
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def actions(entity)
            return [] if entity.company? && !entity.owner
            return [] if entity.company? && entity.owner.player? &&
                        @round.current_operator&.owner != entity.owner

            super
          end
        end
      end
    end
  end
end
