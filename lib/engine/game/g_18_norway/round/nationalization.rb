# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18Norway
      module Round
        class Nationalization < Engine::Round::Operating
          def name
            'Nationalization round'
          end

          def select_entities
            @game.operating_order.reverse
          end

          def show_in_history?
            false
          end
        end
      end
    end
  end
end
