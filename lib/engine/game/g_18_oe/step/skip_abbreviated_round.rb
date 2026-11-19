# frozen_string_literal: true

module Engine
  module Game
    module G18OE
      module Step
        module SkipAbbreviatedRound
          def actions(entity)
            return [] if skip?

            super
          end

          def log_skip(entity)
            return if skip?

            super
          end

          def skip?
            @game.abbreviated_operating_round?
          end
        end
      end
    end
  end
end
