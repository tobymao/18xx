# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1822
      module Round
        class Operating < Engine::Round::Operating
          def recalculate_order
            # Selling shares may have caused the major corporations that haven't operated yet
            # to change order.
            index = @entity_index + 1
            return unless index < @entities.size - 1

            # Find the first major corporation after current operating entity.
            index += @entities[index..-1].find_index { |c| c.type == :major } || 0
            @entities[index..-1] = @entities[index..-1].sort
          end
        end
      end
    end
  end
end
