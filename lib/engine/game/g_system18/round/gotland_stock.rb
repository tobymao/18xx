# frozen_string_literal: true

require_relative '../../../round/stock'

module Engine
  module Game
    module GSystem18
      module Round
        class GotlandStock < Engine::Round::Stock
          def setup
            @newly_floated_corporations = []
            super
          end

          def finish_round
            # Check if any new corporations were floated during this stock round
            if @newly_floated_corporations.empty?
              # No new corporations floated, export trains equal to number of unfloated corporations
              unfloated_count = @game.corporations.count { |c| !c.floated? && c.floatable }
              if unfloated_count.positive?
                @game.log << 'No new corporations floated during stock round'
                @game.log << "Exporting unfloated corporations count #{unfloated_count} train#{unfloated_count > 1 ? 's' : ''}"
                unfloated_count.times do
                  @game.depot.export! unless @game.depot.upcoming.empty?
                end
              end
            end

            # Clear the tracking array for next stock round
            @newly_floated_corporations.clear

            super
          end

          def track_newly_floated(corporation)
            @newly_floated_corporations << corporation
          end
        end
      end
    end
  end
end
