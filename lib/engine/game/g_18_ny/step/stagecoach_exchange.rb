# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class StagecoachExchange < Engine::Step::Base
          ACTIONS = %w[choose pass].freeze

          def description
            'Exchange Stagecoach Token for Corporation Token'
          end

          def actions(_entity)
            return [] unless can_exchange_now?

            ACTIONS
          end

          def active?
            return false unless stagecoach_token
            return true if can_exchange_now?

            remove_stagecoach_token if @game.privates_closed && !corporation&.next_token
            false
          end

          def active_entities
            [stagecoach_token.corporation]
          end

          def can_exchange_now?
            exchangeable? && (current_operator? || @game.privates_closed)
          end

          def current_operator?
            @round.current_operator == stagecoach_token.corporation && !@passed
          end

          def exchange_at_privates_closed?
            @game.privates_closed && exchangeable?
          end

          def exchangeable?
            stagecoach_token && stagecoach_token&.corporation && stagecoach_token.corporation.next_token
          end

          def stagecoach_token
            @game.stagecoach_token
          end

          def choice_available?(entity)
            entity == stagecoach_token.corporation
          end

          def choice_name
            'Exchange Stagecoach token'
          end

          def choices
            %w[Exchange]
          end

          def process_choose(action)
            stagecoach_token.swap!(action.entity.next_token)
            remove_stagecoach_token
            pass!
          end

          def process_pass(action)
            remove_stagecoach_token
            super
          end

          def remove_stagecoach_token
            stagecoach_token.destroy!
            @game.stagecoach_token = nil
          end
        end
      end
    end
  end
end
