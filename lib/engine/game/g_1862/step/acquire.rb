# frozen_string_literal: true

require_relative 'merge'

module Engine
  module Game
    module G1862
      module Step
        class Acquire < G1862::Step::Merge
          def merge_name
            'Acquire'
          end

          def description
            return 'Choose Survivor' if @merging

            'Acquire Corporation'
          end

          def process_choose(action)
            if action.choice == :first
              @log << "#{@merging.last.name} (non-survivor) will merge into #{@merging.first.name} (survivor)"
              survivor = @merging.first
              nonsurvivor = @merging.last
            else
              @log << "#{@merging.first.name} (non-survivor) will merge into #{@merging.last.name} (survivor)"
              survivor = @merging.last
              nonsurvivor = @merging.first
            end
            @game.start_merge(action.entity, survivor, nonsurvivor, :acquire)
            @merging = nil
          end
        end
      end
    end
  end
end
