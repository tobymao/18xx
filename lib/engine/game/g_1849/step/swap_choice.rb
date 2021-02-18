# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1849
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

          def swap_sell(_player, _corporation, _bundle, _pool_share); end

          def choices
            ['Two 10% certs', 'One 20% cert']
          end

          def choice_name
            'Swap for Presidency'
          end

          def process_choose(action)
            choice = action.choice
            entity = action.entity

            if choice == 'Two 10% certs'
              @log << "#{entity.name} chooses two 10% certificates"
              @game.share_pool.swap_double_cert(@game.swap_location, @game.swap_other_player,
                                                @game.swap_corporation)
            else
              @log << "#{entity.name} chooses the 20% last certificate"
            end
            @game.swap_choice_player = nil
            @game.swap_location = nil
            @game.swap_other_player = nil
            @game.swap_corporation = nil
          end
        end
      end
    end
  end
end
