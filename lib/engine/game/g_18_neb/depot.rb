# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G18Neb
      class Depot < Engine::Depot
        def min_depot_train
          current_entity = @game.round.current_operator
          rusted = current_entity&.corporation? && current_entity.type == :local
          depot_trains.select { |t| t.rusted == rusted }.min_by(&:price)
        end
      end
    end
  end
end
