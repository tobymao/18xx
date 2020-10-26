# frozen_string_literal: true

require_relative '../route'

module Engine
  module Step
    module G18LosAngeles
      class Route < Route
        def help
          text = Array(super)

          trains = current_entity.runnable_trains.group_by { |t| @game.train_type(t) }
          if trains.keys.size > 1
            passenger_trains = trains[:passenger].map(&:name).uniq
            freight_trains = trains[:freight].map(&:name).uniq
            text << 'Reminder: the routes of Passenger trains '\
                    "(#{passenger_trains.join(', ')}) may overlap with the "\
                    "routes of Freight trains (#{freight_trains.join(', ')})"
          end

          text
        end
      end
    end
  end
end
