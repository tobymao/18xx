# frozen_string_literal: true

require_relative '../../g_1817/step/acquire'
require_relative 'scrap_train_module'
module Engine
  module Game
    module G18USA
      module Step
        class Acquire < G1817::Step::Acquire
          include ScrapTrainModule
          def actions(entity)
            actions = super
            if entity == @buyer && can_scrap_train?(entity)
              actions = %w[pass] if actions.empty?
              actions << 'scrap_train'
            end
            actions
          end

          def pass_description
            return 'Pass (Scrap Train)' if @buyer && !can_take_loan?(@buyer) && !can_payoff?(@buyer)

            super
          end

          def process_pass(action)
            if @buyer && !can_take_loan?(@buyer) && !can_payoff?(@buyer)
              @passed_scrap_trains = true
              @game.log << "#{@buyer.name} passes scrapping trains"
              acquire_post_loan
            else
              super
            end
          end

          def acquire_post_loan
            return if can_scrap_train?(@buyer)

            super
          end

          # This version is needed to reference @passed_scrap_trains
          def can_scrap_train?(entity)
            return true if entity.corporation? && !@passed_scrap_trains && entity.trains.find { |t| @game.pullman_train?(t) }
          end
        end
      end
    end
  end
end
