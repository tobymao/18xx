# frozen_string_literal: true

require_relative '../../../step/tracker'
require_relative '../../../step/track'

module Engine
  module Game
    module G18CZ
      module Step
        class Track < Engine::Step::Track
          def process_lay_tile(action)
            return super unless @game.corporation_of_vaclav?(action.entity)

            lay_tile_action(action, spender: @game.bank)
            pass! unless can_lay_tile?(action.entity)
          end

          def pass!
            super
            @game.track_action_processed(current_entity)
          end
        end
      end
    end
  end
end
