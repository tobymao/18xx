# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G1837
      class Depot < Engine::Depot
        def available(corporation)
          trains = super
          trains.select! { |t| @game.goods_train?(t.name) } if corporation.type == :coal
          trains
        end
      end
    end
  end
end
