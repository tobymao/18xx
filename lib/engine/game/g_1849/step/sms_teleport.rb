# frozen_string_literal: true

module Engine
  module Game
    module G1849
      module Step
        class SMSTeleport < Engine::Step::Base
          def actions(entity)
            return [] unless entity == current_entity

            @sms = entity.companies.find { |c| c.id == 'SMS' }
            return [] unless @sms

            track_step = @round.steps.find { |step| step.is_a?(Track) }
            token_step = @round.steps.find { |step| step.is_a?(Token) }
            return [] if track_step.acted || token_step.acted

            @passed ? [] : ['choose']
          end

          def description
            'SMS Teleport'
          end

          def active?
            !current_actions.empty?
          end

          def choice_available?(entity)
            entity == current_entity && entity.companies.find { |c| c.id == 'SMS' }
          end

          def can_sell?
            false
          end

          def ipo_type(_entity)
            nil
          end

          def swap_sell(_player, _corporation, _bundle, _pool_share); end

          def choices
            ['Close SMS', 'Pass']
          end

          def choice_name
            'Close SMS to optionally lay/upgrade and/or token on any coastal city'
          end

          def process_choose(action)
            corp = action.entity

            if action.choice == 'Close SMS'
              @log << "#{corp.id} closes SMS"
              @sms.close!
              corp.sms_hexes = @game.sms_hexes
            end
            @passed = true
          end
        end
      end
    end
  end
end
