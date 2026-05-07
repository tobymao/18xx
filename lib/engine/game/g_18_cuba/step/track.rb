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
            # TODO: upgrade logic ensure narrow track connect to narrow track and broad to broad
            corp = entity.corporation? ? entity : @game.current_entity

            # 18Cuba: minors cannot build cities except on their home hex
            return nil if corp.type == :minor &&
                          !hex.tile.cities.empty? &&
                          hex != corp.tokens.first.hex

            super
          end

          def potential_tiles(entity, hex)
            corp = entity.corporation? ? entity : @game.current_entity

            super.reject do |tile|
              @game.tile_blocked_for_corp?(tile, corp, hex)
            end
          end
        end
      end
    end
  end
end
