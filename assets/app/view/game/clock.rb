# frozen_string_literal: true

module View
  module Game
    class Clock < Snabberb::Component
      needs :time_spent
      needs :counting
      needs :last_action

      def render
        secs = @time_spent
        secs += @time_since_last_action if @counting
        mins = (secs / 60).to_i
        hours = (mins / 60).to_i
        days = (hours / 24).to_i

        h(:span, "#{days}D #{(hours % 24).to_s.rjust(2, '0')}:#{(mins % 60).to_s.rjust(2, '0')}")
      end
    end
  end
end
