# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G1849
      class Depot < Engine::Depot
        # this prevents the E train from being chosen as the cheapest train if a corp doesn't have an E-token
        # in the Electric Dreams variant.
        def min_depot_train
          if !@game.e_token?(@game.current_entity)
            depot_trains.reject { |t| t.name == 'E' }.min_by(&:price)
          else
            depot_trains.min_by(&:price)
          end
        end
      end
    end
  end
end
