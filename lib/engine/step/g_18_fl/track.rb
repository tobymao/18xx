# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18FL
      class Track < Track
        def can_lay_tile?(entity)
          super || !@game.tile_company.closed?
        end
      end
    end
  end
end
