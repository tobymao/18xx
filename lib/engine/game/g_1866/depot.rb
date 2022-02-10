# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G1866
      class Depot < Engine::Depot
        def depot_trains(clear: false)
          @depot_trains = nil if clear
          @depot_trains ||= [
            @upcoming.first,
            *ignore_last_train,
            *@upcoming.select { |t| @game.phase.available?(t.available_on) },
          ].compact.uniq(&:name) + @discarded.uniq(&:name)
        end

        def ignore_last_train
          train = @upcoming.first
          return nil if @game.local_train?(train)

          next_trains = []
          last_phase_count = 0
          @upcoming.group_by(&:name).each do |_, phase_trains|
            next_trains << phase_trains.first if last_phase_count == 1
            last_phase_count = phase_trains.size
          end
          next_trains
        end
      end
    end
  end
end
