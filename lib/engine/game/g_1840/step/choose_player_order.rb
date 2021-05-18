# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1840
      module Step
        class ChoosePlayerOrder < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def actions(_entity)
            ACTIONS
          end

          def description
            'Playing Order'
          end

          def choices
            @choices_left
          end

          def choice_name
            description
          end

          def setup
            @choices_left = @game.players.map.with_index { |_item, index| [index, "Position #{index + 1}"] }
          end

          def process_choose(action)
            choice = action.choice
            player = action.entity

            selected_choice = @choices_left.find { |item| item[0] == choice }
            select_choice(player, selected_choice)

            player.pass!

            return finish! if @choices_left.size == 1

            next_entity!
          end

          def next_entity!
            @round.next_entity_index!
            entity = entities[entity_index]
            next_entity! if entity&.passed?
          end

          def finish!
            last_player_left = entities.find(&:active?)
            select_choice(last_player_left, @choices_left.first)

            entities.each(&:unpass!)

            pass!
          end

          def select_choice(player, choice)
            @choices_left.delete(choice)

            @game.set_order_for_first_sr(player, choice.first)

            @log << "#{player.name} chooses #{choice.last}"
          end
        end
      end
    end
  end
end
