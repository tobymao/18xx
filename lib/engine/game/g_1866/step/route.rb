# frozen_string_literal: true

require_relative '../../../step/route'

module Engine
  module Game
    module G1866
      module Step
        class Route < Engine::Step::Route
          def available_hex(entity, hex)
            return nil if @game.national_corporation?(entity) && !@game.hex_within_national_region?(entity, hex)
            return nil if @game.corporation?(entity) && !@game.hex_operating_rights?(entity, hex)

            super
          end
        end
      end
    end
  end
end
