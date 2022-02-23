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

            super
          end

          def pay_interest!(entity)
            # 1817's pay_interest! does a 'return unless step_passed?(Engine::Step::BuyTrain)' which unintentionally
            #   passes for the 18USA BuyPullmanStep - here we check that 18USA BuyTrain is passed before continuing
            return unless step_passed?(G18USA::Step::BuyTrain)

            super
          end
        end
      end
    end
  end
end
