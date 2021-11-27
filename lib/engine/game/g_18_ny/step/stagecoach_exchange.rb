# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class StagecoachExchange < Engine::Step::Base
          CHOOSE_ACTIONS = %w[choose].freeze
          REPLACE_ACTIONS = %w[remove_token].freeze

          def description
            'Exchange Stagecoach Token for Corporation Token'
          end

          def actions(entity)
            return CHOOSE_ACTIONS if exchange_at_privates_closed?
            return [] unless current_entity == entity
            return [] unless entity == stagecoach_token&.corporation

            REPLACE_ACTIONS
          end

          def active?
            sc_corp = stagecoach_token&.corporation
            return false unless sc_corp
            return true if sc_corp.next_token && (@game.privates_closed || sc_corp == @round.current_operator)

            # No token, so no choice to be made
            if @game.privates_closed
              @game.log << 'Stagecoach Token is removed from play'
              remove_stagecoach_token(sc_corp)
            end
            false
          end

          def blocks?
            exchange_at_privates_closed?
          end

          def active_entities
            [stagecoach_token&.corporation].compact
          end

          def exchange_at_privates_closed?
            @game.privates_closed && stagecoach_token && stagecoach_token&.corporation&.next_token
          end

          def stagecoach_token
            @game.stagecoach_token
          end

          def stagecoach_token=(val)
            @game.stagecoach_token = val
          end

          def hexes
            [@game.albany_hex]
          end

          def can_replace_token?(_entity, token)
            token == stagecoach_token
          end

          def process_remove_token(action)
            @game.log << "#{action.entity.name} replaces the Stagecoach Token with one of its available tokens"
            replace_stagecoach_token(action.entity)
          end

          def choice_available?(entity)
            entity == stagecoach_token&.corporation
          end

          def choice_name
            'Stagecoach Token'
          end

          def choices
            %w[Replace Remove]
          end

          def process_choose(action)
            entity = action.entity
            raise GameError, "#{entity.name} does not own the Stagecoach Token" if entity != stagecoach_token&.corporation

            if action.choice == 'Replace'
              @game.log << "#{entity.name} replaces the Stagecoach Token with one of its available tokens"
              replace_stagecoach_token(entity)
            else
              @game.log << "#{entity.name} declines to replace the Stagecoach Token and the token is removed from play"
              remove_stagecoach_token(entity)
            end
          end

          def replace_stagecoach_token(entity)
            stagecoach_token.swap!(entity.next_token)
            remove_stagecoach_token(entity)
          end

          def remove_stagecoach_token(entity)
            stagecoach_token.destroy!
            self.stagecoach_token = nil
            @game.remove_stagecoach_token_exchange_ability(entity)
          end
        end
      end
    end
  end
end
