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
            return [] unless @game.mandatory_coal_minor_exchange?(entity)

            [Action::Choose.new(entity, choice: CHOICES[:exchange])]
          end

          def description
            'Exchange'
          end

          def can_exchange?(entity)
            !entity.closed? && @game.coal_minor?(entity)
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
              @log << "#{entity.id} must be exchanged" if @game.mandatory_coal_minor_exchange?(entity)
              @game.exchange_coal_minor(entity)
            else
              @log << "#{entity.id} declines exchange"
              pass!
            end
          end

          def log_skip(entity)
            @log << "#{entity.id} cannot exchange" if @game.coal_minor?(entity)
          end
        end
      end
    end
  end
end
