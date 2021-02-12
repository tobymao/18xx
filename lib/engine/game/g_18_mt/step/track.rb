# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18MT
      module Step
        class Track < Engine::Step::Track
          def upgradeable_tiles(entity, ui_hex)
            tiles = super

            tiles.reject! { |t| t.name == '338' } if tiles.any? { |t| t.name == '770' }
            tiles.reject! { |t| t.name == '770' } if tiles.any? { |t| t.name == '63' }

            tiles
          end
        end
      end
    end
  end
end
