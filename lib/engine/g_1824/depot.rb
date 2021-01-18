# frozen_string_literal: true

require_relative '../depot'

module Engine
  module G1824
    class Depot < Depot
      def depot_trains(clear: false)
        @depot_trains = nil if clear
        @depot_trains ||= [
          @upcoming.reject { |t| @game.g_train?(t) }.first,
          *@upcoming.select { |t| @game.phase.available?(t.available_on) },
        ].compact.uniq(&:name) + @discarded.uniq(&:name)
      end
    end
  end
end
