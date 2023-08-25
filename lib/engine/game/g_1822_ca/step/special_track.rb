# frozen_string_literal: true

require_relative '../../g_1822/step/special_track'
require_relative 'tracker'

module Engine
  module Game
    module G1822CA
      module Step
        class SpecialTrack < G1822::Step::SpecialTrack
          include G1822CA::Tracker

          def available_hex(entity_or_entities, hex)
            if hex == @game.sawmill_hex
              super && Array(entity_or_entities).none? { |e| @game.must_remove_town?(e) }
            else
              super
            end
          end

          def actions(entity)
            return [] unless entity.company?

            super
          end
        end
      end
    end
  end
end
