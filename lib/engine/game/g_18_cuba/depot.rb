# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G18Cuba
      class Depot < Engine::Depot
        # Engine's emergency-buy trigger keys off
        # min_depot_price / min_depot_train; we only narrow the candidate set when
        # the current entity actually needs a regular (non-wagon, gauge-matching)
        # train. Once it owns one, fall back to the engine's global minimum.
        def min_depot_train
          current_entity = @game.round.current_entity
          return super unless current_entity
          # super's global min is only read under president_may_contribute? (trainless), so the fallback is safe.
          return super unless @game.trainless?(current_entity)

          gauge = @game.gauge_for(current_entity)
          depot_trains.reject { |t| @game.wagon?(t) || t.track_type != gauge }.min_by(&:price)
        end

        # FC trains never leave it (rule VII.16); by owner, as Train#variant= would reset buyable.
        def other_trains(corporation)
          super.reject { |t| t.owner == @game.fc }
        end
      end
    end
  end
end
