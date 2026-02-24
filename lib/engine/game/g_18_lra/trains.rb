# frozen_string_literal: true

module Engine
  module Game
    module G18Lra
      module Trains
        def num_trains(train)
          case train[:name]
          when '2'
            optional_2_train ? 6 : 5
          when '3'
            4
          when '4', '5'
            2
          when '6'
            6
          when '8'
            0
          end
        end

        def game_trains
          trains = super

          # Inject remove_tile_block event
          trains.each do |t|
            t[:events] = [{ 'type' => 'remove_tile_block' }] if t[:name] == '3'
            t[:events] << { 'type' => 'gbk_floats' } if t[:name] == '5'
          end
          trains
        end
      end
    end
  end
end
