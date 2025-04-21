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
        end
      end
    end
  end
end
