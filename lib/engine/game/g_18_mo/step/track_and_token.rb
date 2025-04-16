# frozen_string_literal: true

require_relative '../../g_1846/step/track_and_token'

module Engine
  module Game
    module G18MO
      module Step
        class TrackAndToken < G1846::Step::TrackAndToken
          def process_place_token(action)
            super
            @game.remove_teleport_destination(action.entity, action.city)
          end

          def tokener_available_hex(entity, hex)
            entity.all_abilities.each do |ability|
              return true if ability.type == :token && ability.hexes.include?(hex.id)
            end
            super
          end
        end
      end
    end
  end
end
