# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module G18GB
      module Round
        class Stock < Engine::Round::Stock
          attr_accessor :presidencies

          def start_entity
            super

            @presidencies = @game.corporations.select { |corp| corp.president?(current_entity) }
          end
        end
      end
    end
  end
end
