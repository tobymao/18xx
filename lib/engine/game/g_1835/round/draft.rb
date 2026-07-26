# frozen_string_literal: true

require_relative '../../../round/draft'

module Engine
  module Game
    module G1835
      module Round
        class Draft < Engine::Round::Draft
          def finished?
            @entities.all?(&:passed?) || @game.companies.all? { |c| c.owner || c.closed? }
          end

          def next_entity_index!
            @entity_index = (@entity_index + 1) % @entities.size
          end
        end
      end
    end
  end
end
