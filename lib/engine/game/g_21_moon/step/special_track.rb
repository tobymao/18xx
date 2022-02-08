# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G21Moon
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def process_lay_tile(action)
            super

            @round.num_laid_track -= 1

            entity = @game.token_owner(action.entity)
            hex = action.hex
            city = action.tile.cities.first
            token = entity.find_token_by_type
            return unless token

            tokener = "#{entity.name} (#{action.entity.sym})"

            city.place_token(entity, token, free: true)
            @log << "#{tokener} places a token on #{hex.name} (#{hex.location_name})"
            @log << "#{action.entity.name} Company closes"
            action.entity.close!

            @game.hb_graph.clear
            @game.sp_graph.clear
            @game.graph.clear
          end

          def track_upgrade?(_from, _to, _hex)
            false
          end
        end
      end
    end
  end
end
