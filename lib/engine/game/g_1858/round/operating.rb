# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1858
      module Round
        class Operating < Engine::Round::Operating
          def next_entity!
            after_operating(@entities[@entity_index])
            super
          end

          def after_operating(entity)
            return unless entity.corporation?

            # Any private companies owned by a public company close at the end
            # of its operating turn. We need to iterate backwards over the array
            # as company.close! modifies the array and will break the enumerator
            # if there are multiple companies to close and we are going forwards.
            entity.companies.reverse_each { |company| @game.close_company(company) }
          end
        end
      end
    end
  end
end
