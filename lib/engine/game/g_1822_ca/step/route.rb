# frozen_string_literal: true

require_relative '../../g_1822/step/route'

module Engine
  module Game
    module G1822CA
      module Step
        class Route < G1822::Step::Route
          def attach_pullman
            @orginal_train = @pullman_train.dup
            distance = train_city_distance(@pullman_train)

            towns = 2 * distance

            @pullman_train.name += "+#{towns}"
            @pullman_train.distance = [
              {
                'nodes' => %w[city offboard],
                'pay' => distance,
                'visit' => distance,
              },
              {
                'nodes' => ['town'],
                'pay' => towns,
                'visit' => towns,
              },
            ]
          end
        end
      end
    end
  end
end
