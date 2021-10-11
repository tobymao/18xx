# frozen_string_literal: true

require_relative '../../g_1817/round/operating'

module Engine
  module Game
    module G18USA
      module Round
        class Operating < G1817::Round::Operating
          def after_process(action)
            # Keep track of last_player for Cash Crisis
            entity = @entities[@entity_index]
            @cash_crisis_player = entity.player
            pay_interest!(entity)

            if !active_step && entity.operator? && entity.trains.reject { |t| @game.pullman_train?(t) }.empty?
              @log << "#{entity.name} has no trains and liquidates"
              @game.liquidate!(entity)
            end

            super
          end
        end
      end
    end
  end
end
