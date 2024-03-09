# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G1854
      class Depot < Engine::Depot
        def depot_trains(clear: false)
          d_trains = super
          d_trains.reject! { |t| t.name == '3+' } if @game.depot.upcoming.any? { |t| t.name == '2+' }
          d_trains.reject! { |t| t.name == '2+' } if @game.depot.upcoming.any? { |t| t.name == '1+' }
          d_trains
        end
      end
    end
  end
end
