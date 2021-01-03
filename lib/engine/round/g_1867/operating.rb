# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G1867
      class Operating < Operating
        def select_entities
          minors, majors = @game.corporations.select(&:floated?).sort.partition { |c| c.type == :minor }
          minors + majors
        end

        def start_operating
          super

          # Skip closed minors
          entity = @entities[@entity_index]
          next_entity! unless @game.corporations.include?(entity)
        end
      end
    end
  end
end
