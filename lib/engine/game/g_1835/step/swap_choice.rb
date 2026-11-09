# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1835
      module Step
        class SwapChoice < Engine::Step::Base
          def actions(entity)
            return [] unless entity == current_entity

            ['choose']
          end

          def active_entities
            return [] unless @game.swap_choice_player

            [@game.swap_choice_player]
          end

          def description
            'Presidency Swap Choice'
          end

          def active?
            !active_entities.empty?
          end

          def choice_available?(entity)
            entity == @game.swap_choice_player
          end

          def can_sell?
            false
          end

          def ipo_type(_entity)
            nil
          end

          def choices
            choices = {}
            choices['keep_one'] = "Keep one #{denominations[0]}% cert"
            choices['swap_for_two'] = "Swap for two #{denominations[1]}% certs"
            choices
          end

          def choice_name
            'Swap for Presidency'
          end

          def process_choose(action)
            choice = action.choice
            entity = action.entity

            case choice
            when 'swap_for_two'
              @log << "#{entity.name} chooses to swap for two #{denominations[1]}% certificates"
              @game.share_pool.swap(@game.swap_location, @game.swap_other_player, @game.swap_corporation, denominations[0])
            else
              @log << "#{entity.name} chooses to keep the #{denominations[0]}% certificate"
            end

            @game.swap_choice_player = nil
            @game.swap_location = nil
            @game.swap_other_player = nil
            @game.swap_corporation = nil
          end

          private

          def denominations
            @game.swap_corporation == @game.prussian ? [10, 5] : [20, 10]
          end
        end
      end
    end
  end
end
