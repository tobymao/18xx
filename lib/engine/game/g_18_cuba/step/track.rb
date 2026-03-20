# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G18Cuba
      module Step
        class Track < Engine::Step::Track
          def tracker_available_hex(entity, hex)
            # TODO: FC logic with fee payments
            corp = entity.corporation? ? entity : @game.current_entity

            # 18Cuba: minors cannot build cities except on their home hex
            return nil if corp.type == :minor &&
                          !hex.tile.cities.empty? &&
                          hex != corp.tokens.first.hex

            super
          end

          def potential_tiles(entity, hex)
            # TODO: upgrade logic to be checked
            corp = entity.corporation? ? entity : @game.current_entity

            super.reject do |tile|
              @game.tile_blocked_for_corp?(tile, corp)
            end
          end
        end
      end
    end
  end
end
