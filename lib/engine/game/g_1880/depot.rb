# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G1880
      class Depot < Engine::Depot
        def min_depot_train
          # 2p doesn't count towards needing a train, should be ignored when checking for min
          depot_trains.reject { |t| t.name == '2P' }.min_by(&:price)
        end
      end
    end
  end
end
