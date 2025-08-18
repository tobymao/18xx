# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G18Norway
      class Depot < Engine::Depot
        def min_depot_train
          current_entity = @game.round.current_entity
          return super if current_entity.trains.any? { |train| !@game.ship?(train) }

          # Ships doesn't count towards needing a train, should be ignored when checking for min
          depot_trains.reject { |train| @game.ship?(train) }.min_by(&:price)
        end
      end
    end
  end
end
