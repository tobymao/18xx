# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G1880
      module Step
        class Track < Engine::Step::Track
          def max_exits(tiles)
            # Ignore max exits for city/town option upgrades
            return tiles if tiles.any? { |t| !t.towns.empty? }

            super
          end
        end
      end
    end
  end
end
