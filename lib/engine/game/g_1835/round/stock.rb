# frozen_string_literal: true

require_relative '../../../round/stock'
module Engine
  module Game
    module G1835
      module Round
        class Stock < Engine::Round::Stock
          attr_accessor :turns_since_last_purchase

          def setup
            @turns_since_last_purchase = 0
            super
          end

          def finished?
            super || @turns_since_last_purchase > @entities.size
          end

          def next_entity_index!
            @turns_since_last_purchase += 1
            super
          end
        end
      end
    end
  end
end
