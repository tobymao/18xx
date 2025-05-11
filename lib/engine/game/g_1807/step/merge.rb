# frozen_string_literal: true

require_relative '../../g_1867/step/merge'

module Engine
  module Game
    module G1807
      module Step
        class Merge < G1867::Step::Merge
          def mergeable(corporation)
            if @converting || @merge_major
              @game.corporations.select do |target|
                target.type == :public &&
                !target.floated?
              end
            else
              mergeable_candidates(corporation)
            end
          end

          private

          def london_token?(corporation)
            corporation.placed_tokens.map(&:city).intersect?(@game.london_cities)
          end

          def connected_cities(corporation)
            return super unless london_token?(corporation)

            super | @game.london_cities
          end
        end
      end
    end
  end
end
