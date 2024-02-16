# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module GSystem18
      class Depot < Engine::Depot
        def depot_trains(clear: false)
          return super unless @game.map_name == 'uk_limited'

          @depot_trains = nil if clear
          @depot_trains ||= @upcoming.select { |t| @game.phase.available?(t.name) }.compact.uniq(&:name) +
            @discarded.uniq(&:name)
        end
      end
    end
  end
end
