# frozen_string_literal: true

require_relative '../../g_1822/step/pending_token'

module Engine
  module Game
    module G1822CA
      module Step
        class PendingToken < G1822::Step::PendingToken
          def setup_m14_track_rights(_m14); end

          def process_place_token(action)
            if action.entity == @game.qmoo &&
               action.city.hex == @game.quebec_hex &&
               action.city.available_slots.zero?
              raise GameError, "Cannot place QMOO's home token in occupied or reserved city"
            end

            super
          end
        end
      end
    end
  end
end
