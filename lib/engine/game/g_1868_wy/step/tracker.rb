# frozen_string_literal: true

require_relative '../../../step/tracker'

module Engine
  module Game
    module G1868WY
      module Step
        module Tracker
          def lay_tile_action(action, **kwargs)
            super
            @game.spend_tile_lay_points(action)
          end

          def tracker_available_hex(entity, hex, check_billings: true)
            if @game.billings_hex?(hex)
              super(entity, hex) ||
                (check_billings && tracker_available_hex(entity, @game.other_billings(hex), check_billings: false))
            else
              super(entity, hex)
            end
          end
        end
      end
    end
  end
end
