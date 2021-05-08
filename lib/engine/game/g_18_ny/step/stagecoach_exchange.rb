# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class StagecoachExchange < Engine::Step::Base
          def description
            'Exchange Token for Stagecoach Token'
          end

          def actions(_entity)
            return %w[choose pass] if active?

            []
          end

          def active?
            return false unless @game.stagecoach_token
            return false if @passed && !@game.privates_closed

            corporation = @game.stagecoach_token&.corporation
            # Remove token if privates are closed and it can't be exchanged
            remove_stagecoach_token if @game.privates_closed && !corporation&.next_token

            (@game.stagecoach_token && @game.privates_closed) ||
              (corporation == @game.round.current_operator && corporation.next_token)
          end

          def active_entities
            [@game.stagecoach_token.corporation]
          end

          def choice_available?(entity)
            entity == @game.stagecoach_token.corporation
          end

          def choice_name
            'Exchange Stagecoach token'
          end

          def choices
            %w[Exchange]
          end

          def process_choose(action)
            @game.stagecoach_token.swap!(action.entity.next_token)
            remove_stagecoach_token
            pass!
          end

          def process_pass(action)
            remove_stagecoach_token if @game.privates_closed
            super
          end

          def remove_stagecoach_token
            @game.stagecoach_token.destroy!
            @game.stagecoach_token = nil
          end
        end
      end
    end
  end
end
