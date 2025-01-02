# frozen_string_literal: true

module Engine
  module Game
    module G18Norway
      module Step
        class TriggerNationalization < Engine::Step::Base
          def description
            'Trigger nationalization sequence'
          end

          def actions(_entity)
            %w[choose pass]
          end

          def auto_actions(entity)
            return [] unless entity.corporation?
            return [Engine::Action::Pass.new(entity)] unless @game.operating_order.last == entity
            return [Engine::Action::Pass.new(entity)] if !@game.phase.tiles.include?(:green) && @round.round_num == 2

            [Engine::Action::Choose.new(entity, choice: ['1'])]
          end

          def choice_name
            'Trigger nationalization'
          end

          def log_skip(entity); end

          def choices
            choices_hash = {}
            choices_hash['1'] = 'Trigger nationalization'
            choices_hash
          end

          def process_choose(_action)
            @game.reset_nationalization_candidates
            pass!
          end
        end
      end
    end
  end
end
