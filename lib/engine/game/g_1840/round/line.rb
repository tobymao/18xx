# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1840
      module Round
        class Line < Engine::Round::Operating
          def select_entities
            @game.operating_order.select { |item| item.type == :minor }.sort_by { |item| item.id.to_i }
          end

          def self.short_name
            'LR'
          end

          def name
            'Line Round'
          end

          def after_process(action)
            entity = @entities[@entity_index]
            if action.is_a?(Engine::Action::RunRoutes) && !action.routes.empty?
              process_action(Engine::Action::Dividend.new(entity,
                                                          kind: 'withhold'))
            end
            super
          end
        end
      end
    end
  end
end
