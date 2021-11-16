# frozen_string_literal: true

require_relative 'merge'

module Engine
  module Game
    module G1862
      module Step
        class Acquire < G1862::Step::Merge
          def merge_name(_entity = nil)
            'Acquire'
          end

          def description
            return 'Choose Survivor' if @merging

            'Acquire'
          end

          def process_choose(action)
            choose_action(action, :acquire)
          end
        end
      end
    end
  end
end
