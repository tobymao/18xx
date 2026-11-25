# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G18OE
      class Depot < Engine::Depot
        def min_depot_train
          depot_trains.reject { |train| train.rusted || @game.extra_train?(train) }.min_by(&:price)
        end

        def rusted_trains
          @discarded.select(&:rusted)
        end
      end
    end
  end
end
