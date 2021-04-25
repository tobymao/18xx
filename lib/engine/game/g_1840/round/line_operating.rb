# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G1840
      module Round
        class LineOperating < Engine::Round::Operating
          def select_entities
            @game.operating_order.select { |item| item.type == :minor }.sort_by(&:id)
          end

          def self.short_name
            'LR'
          end

          def name
            'Line Round'
          end

          def after_process(action)
            entity = @entities[@entity_index]
            case action
            when Engine::Action::RunRoutes
              process_action(Engine::Action::Dividend.new(entity, kind: 'payout')) unless action.routes.empty?
            end
            super
          end
        end
      end
    end
  end
end
