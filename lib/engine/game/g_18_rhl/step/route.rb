# frozen_string_literal: true

require_relative '../../../game_error'
require_relative '../../../step/route'

module Engine
  module Game
    module G18Rhl
      module Step
        class Route < Engine::Step::Route
          def chart(_entity)
            [
              ['Bonus/Penalty', 'Revenue'],
              ['Montan', "#{@game.format_currency(20)}/#{@game.format_currency(40)} per K/S pair"],
              ['Eastern Ruhr', "#{@game.format_currency(10)} per link"],
              ['ERh', @game.format_currency(80)],
              ['Trajekt', @game.format_currency(-10)],
              %w[RGE Special],
              ['Offboard', 'No revenue if out-tokened'],
            ]
          end
        end
      end
    end
  end
end
