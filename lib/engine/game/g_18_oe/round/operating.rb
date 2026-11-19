# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Round
    module G18OE
      class Operating < Engine::Round::Operating
        attr_reader :operating_position_entity, :operating_position

        def choose_operating_position!(entity, position)
          @operating_position_entity = entity
          @operating_position = position
          move_operating_position!
          @current_operator = @entities[@entity_index]
        end

        def recalculate_order
          super
          move_operating_position!(@entity_index + 1)
        end

        private

        def move_operating_position!(start_index = 0)
          entity = @operating_position_entity
          return unless entity
          return unless %w[first last].include?(@operating_position)

          types = entity.type == :minor ? %i[minor regional] : %i[major national]
          group = @entities.drop(start_index).select { |corporation| types.include?(corporation.type) }
          return unless group.include?(entity)

          target = @operating_position == 'first' ? group.first : group.last
          index = @entities.index(target)
          @entities.delete(entity)
          @entities.insert(index, entity)
        end
      end
    end
  end
end
