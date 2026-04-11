# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1835
      module Round
        class Operating < Engine::Round::Operating
          def setup
            super
            # Initialize merged trains tracking for this round
            @merged_trains = Hash.new { |h, k| h[k] = [] }
          end

          def after_process(action)
            super
            @game.check_company_closings
          end

          attr_reader :merged_trains
        end
      end
    end
  end
end
