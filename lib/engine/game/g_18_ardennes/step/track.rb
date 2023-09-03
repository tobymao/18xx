# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Track < Engine::Step::Track
          def lay_tile_action(action, entity: nil, spender: nil)
            super
            collect_forts(action.hex, action.entity)
          end

          def collect_forts(hex, corporation)
            return unless @game.fort_hexes.include?(hex)

            # TODO: collecting fort tokens is optional
            hex.tokens.each do |fort|
              fort.remove!
              corporation.assign!(hex.coordinates)
            end
          end
        end
      end
    end
  end
end
