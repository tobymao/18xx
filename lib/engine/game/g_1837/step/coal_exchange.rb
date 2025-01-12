# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1837
      module Step
        class CoalExchange < Engine::Step::Base
          ACTIONS = %w[choose].freeze
          CHOICES = { :exchange => 'Exchange', :pass => 'Decline' }.freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless can_exchange?(entity)

            ACTIONS
          end

          def auto_actions(entity)
            return [] unless @game.mandatory_coal_company_exchange?(entity)

            [Action::Choose.new(entity, choice: CHOICES[:exchange])]
          end

          def description
            'Exchange'
          end

          def can_exchange?(entity)
            entity.company? && !entity.closed?
          end

          def choice_name
            "Exchange for #{exchange_target(current_entity).id} share"
          end

          def choices
            CHOICES.values
          end

          def exchange_target(entity)
            @game.exchange_target(entity)
          end

          def process_choose(action)
            entity = action.entity
            if action.choice == CHOICES[:exchange]
              @log << "#{entity.sym} must be exchanged" if @game.mandatory_coal_company_exchange?(entity)
              @game.exchange_coal_company(entity)
            else
              @log << "#{entity.sym} declines exchange"
            end
            pass!
          end

          def log_skip(entity)
            @log << "#{entity.sym} cannot exchange" if entity.company?
          end
        end
      end
    end
  end
end
