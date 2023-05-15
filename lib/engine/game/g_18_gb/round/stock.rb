# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18GB
      module Round
        class Stock < Engine::Round::Stock
          attr_accessor :presidencies

          def record_current_presidencies
            @presidencies = @game.corporations.select { |corp| corp.president?(current_entity) }
          end

          def setup
            super

            record_current_presidencies
          end

          def start_entity
            super

            record_current_presidencies
          end
        end
      end
    end
  end
end
