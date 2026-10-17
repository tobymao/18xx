# frozen_string_literal: true

require_relative '../../g_1867/round/operating'

module Engine
  module Game
    module G1864
      module Round
        class Operating < G1867::Round::Operating
          def skip_entity?(entity)
            return !entity.owner if entity == @game.union_pacific

            super
          end

          def after_setup
            @game.up_without_president! if presidentless_up?(@entities[@entity_index])

            super
          end

          def next_entity_index!
            super
            @game.up_without_president! if presidentless_up?(@entities[@entity_index])
          end

          private

          def presidentless_up?(entity)
            entity == @game.union_pacific && !entity.owner
          end
        end
      end
    end
  end
end
