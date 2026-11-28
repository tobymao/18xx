# frozen_string_literal: true

require_relative '../../depot'

module Engine
  module Game
    module G18OE
      class Depot < Engine::Depot
        def min_depot_train
          depot_trains.reject { |train| train.rusted || @game.extra_train?(train) }.min_by(&:price)
        end

        def rusted_trains
          @discarded.select(&:rusted)
        end

        def depot_trains(clear: false)
          open = @game.non_starter_trains_available?
          clear ||= open != @level_3_open
          @level_3_open = open
          super(clear: clear)
        end

        def available_upcoming_trains
          trains = super
          return trains unless @level_3_open

          level_3 = @upcoming.find { |train| train.name != '2+2' && !@game.extra_train?(train) }
          (trains + [level_3]).compact.uniq(&:name)
        end
      end
    end
  end
end
