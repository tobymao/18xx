# frozen_string_literal: true

require_relative '../../../step/discard_train'

module Engine
  module Game
    module G1828
      module Step
        class DiscardTrain < Engine::Step::DiscardTrain
          def round_state
            super.merge(
              {
                ignore_train_limit: false,
              }
            )
          end

          def crowded_corps
            return [] if @round.ignore_train_limit

            super.reject(&:system?).concat(crowded_systems)
          end

          def crowded_systems
            @game.corporations.select do |c|
              c.system? && c.shells.any? { |shell| shell.trains.size > @game.train_limit(c) }
            end
          end

          def trains(corporation)
            return super unless corporation.system?

            corporation.shells.find { |s| s.trains.size > @game.train_limit(corporation) }.trains
          end
        end
      end
    end
  end
end
