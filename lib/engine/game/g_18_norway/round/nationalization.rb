# frozen_string_literal: true

require_relative '../../../round/operating'

module Engine
  module Game
    module G18Norway
      module Round
        class Nationalization < Engine::Round::Operating
          def initialize(game, steps, **opts)
            super
            @nationalization_complete = false
          end

          attr_accessor :nationalization_complete

          def name
            'Nationalization round'
          end

          def select_entities
            @game.operating_order.reverse
          end

          def show_in_history?
            false
          end

          def self.short_name
            'Nationalization'
          end
        end
      end
    end
  end
end
