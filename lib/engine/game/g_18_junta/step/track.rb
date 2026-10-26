# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Junta
      module Step
        # Rules summary 4.1 and 4.2: the normal Track step, plus the Upgrade License. A license held for
        # this Operating Round is used by an upgrade, and expires at the end of the Track step if unused.
        class Track < Engine::Step::Track
          def process_lay_tile(action)
            # The Laguna tile upgrades straight from yellow to gray (7.3), so the tile color is checked
            # against the phase here as well.
            color = action.tile.color
            unless @game.phase.tiles.include?(color)
              raise GameError, "#{color.to_s.capitalize} tiles are not available in phase #{@game.phase.name}"
            end

            super

            entity = action.entity
            @log << "#{entity.name} uses its Upgrade License" if @round.upgraded_track && @game.consume_upgrade_license!(entity)
            @game.expire_upgrade_license_if_unused!(entity) unless can_lay_tile?(entity)
          end

          def process_pass(action)
            super

            @game.expire_upgrade_license_if_unused!(action.entity)
          end

          def skip!
            entity = current_entity
            super
            @game.expire_upgrade_license_if_unused!(entity) if entity&.corporation?
          end
        end
      end
    end
  end
end
