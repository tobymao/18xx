# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G1824
      class Depot < Engine::Depot
        def depot_trains(clear: false)
          @depot_trains = nil if clear
          @depot_trains ||= [
            first_normal_upcoming_train,
            *@upcoming.select { |t| @game.phase.available?(t.available_on) },
          ].compact.uniq(&:name) + @discarded.uniq(&:name)
        end

        def export!
          train = first_normal_upcoming_train
          @game.log << "-- Event: A #{train.name} train exports --"
          remove_train(train)
          @game.phase.buying_train!(nil, train, self)
        end

        private

        def first_normal_upcoming_train
          @upcoming.reject { |t| @game.g_train?(t) }.first
        end
      end
    end
  end
end
