# frozen_string_literal: true

require 'view/game/part/label'

module View
  module Game
    module Part
      class Reservation < Label
        needs :reservation

        def render_part
          h(:g, { attrs: { transform: "#{translate} #{rotation_for_layout}" } }, [
            h('text.tile__text', { attrs: { transform: 'scale(1.1)' } }, @reservation),
          ])
        end
      end
    end
  end
end
