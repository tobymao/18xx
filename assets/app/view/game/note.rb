# frozen_string_literal: true

module View
  module Game
    class Note < Snabberb::Component
      include Actionable
      needs :game

      def render
        round = @game.round
        step = round.active_step
        entity = step.current_entity
        return '' unless entity

        children = []
        if step.respond_to?(:show_note?) && step.show_note?(entity) && step.respond_to?(:note_text_block)
          note = step.note_text_block.map { |text_block| h(:p, text_block) }
          children << h(:div, { style: { marginTop: '0.5rem' } }, note)
        end
        h(:div, children)
      end
    end
  end
end
