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

          def finished?
            return false unless super

            unless @train_export_triggered
              @game.export_train
              @train_export_triggered = true
            end

            true
          end
        end
      end
    end
  end
end
