# frozen_string_literal: true

require_relative '../../g_18_rhineland/step/route'

module Engine
  module Game
    module G18Rhl
      module Step
        class Route < G18Rhineland::Step::Route
          def chart(_entity)
            bonuses = super
            bonuses << ['Ratingen', @game.format_currency(30)] if @game.ratingen_variant
            bonuses
          end
        end
      end
    end
  end
end
