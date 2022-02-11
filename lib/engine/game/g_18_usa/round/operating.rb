# frozen_string_literal: true

require_relative '../../g_1817/round/operating'

module Engine
  module Game
    module G18USA
      module Round
        class Operating < G1817::Round::Operating
          def setup
            super
            @train_export_triggered = false
          end

          def after_process(action)
            super
            return if !finished? || @train_export_triggered

            @game.export_train
            @train_export_triggered = true
          end
        end
      end
    end
  end
end
