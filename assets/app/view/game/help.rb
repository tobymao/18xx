# frozen_string_literal: true

module View
  module Game
    class Help < Snabberb::Component
      needs :game

      def render
        help_text = @game.round.active_step&.help || ''
        return '' if help_text.empty?

        h('div', Array(help_text).map { |l| h('div', l) })
      end
    end
  end
end
