# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    module Round
      class RequestUndo < Snabberb::Component
        include Actionable

        def render
          step = @game.active_step
          h(:div, [h(:h3, step.undo_message)])
        end
      end
    end
  end
end
