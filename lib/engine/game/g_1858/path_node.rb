# frozen_string_literal: true

require_relative '../../part/node'

module Engine
  module Game
    module G1858
      module Part
        # This class exists to allow an Engine::Part:Path to be converted to an
        # Engine::Part::Node. This is needed for tracing routes out from plain
        # track segments on tiles in private company home hexes, if there are
        # no existing nodes connected to the path.
        class PathNode < Engine::Part::Node
          def initialize(path)
            @path = path
          end

          def paths
            [@path]
          end

          def inspect
            "<#{self.class.name}: hex: #{@path.hex.coordinates}, " \
              "exits: #{@path.exits.join(',')}, track: #{@path.track}>"
          end
        end
      end
    end
  end
end
