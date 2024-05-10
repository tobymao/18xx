# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G1849
      class Depot < Engine::Depot
        def min_depot_train_no_e_token
          # this prevents the E train from being chosen as the cheapest train if a corp doesn't have an E-token
          # in the Electric Dreams variant
          depot_trains.reject { |t| t.name == 'E' }.min_by(&:price)
        end
      end
    end
  end
end
