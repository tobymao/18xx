# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G1848
      class Depot < Engine::Depot
        def export!
          train = @upcoming.first
          return if train.rusts_on # only export if upcoming train is permanent

          @game.log << "-- Event: A #{train.name} train exports --"
          remove_train(train)
          @game.phase.buying_train!(nil, train, self)
        end

        def min_depot_train
          # 2e doesn't count towards needing a train, should be ignored when checking for min
          depot_trains.reject { |t| t.name == '2E' }.min_by(&:price)
        end
      end
    end
  end
end
