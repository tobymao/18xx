# frozen_string_literal: true

require_relative 'dividend'

module Engine
  module Game
    module GSystem18
      module Step
        class ConnectionDividend < GSystem18::Step::Dividend
          def actions(entity)
            return [] unless @round.finished_destination[entity]

            super
          end

          def skip!; end

          def description
            'Pay or withold destination dividends'
          end

          def share_price_change(_entity, _revenue)
            {}
          end

          def process_dividend(action)
            super
            action.entity.trains.each { |train| train.operated = false }
            @game.destinate(action.entity)
            @round.connection_available[action.entity] = false
            @round.finished_destination[action.entity] = false
          end
        end
      end
    end
  end
end
