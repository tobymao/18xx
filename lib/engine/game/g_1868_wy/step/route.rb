# frozen_string_literal: true

require_relative '../../../step/route'
require_relative '../skip_coal_and_oil'

module Engine
  module Game
    module G1868WY
      module Step
        class Route < Engine::Step::Route
          include G1868WY::SkipCoalAndOil

          def available_hex(entity, hex, check_billings: true)
            if (spike = @game.spike_hex?(hex))
              @game.spike_hex_available?(spike) { |h| super(entity, h) }
            else
              super(entity, hex)
            end
          end

          def process_run_routes(action)
            super
            @game.check_spikes!(action.routes)
          end
        end
      end
    end
  end
end
