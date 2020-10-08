# frozen_string_literal: true

require_relative '../track'

module Engine
    module Step
        module G18CO
            class Track < Track
                def process_lay_tile(action)
                    lay_tile_action(action)

                    # TODO - Implement Mine Collection
                    @log << "TODO: implement mine token collection"

                    pass! unless can_lay_tile?(action.entity)
                end
            end
        end
    end
end
  