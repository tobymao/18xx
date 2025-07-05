# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module GSystem18
      module Step
        class DifficultySelection < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          DIFFICULTY_CHOICES = {
            'easy' => 'Easy',
            'normal' => 'Normal',
            'hard' => 'Hard',
            'very_hard' => 'Very Hard',
          }.freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if @game.difficulty_level

            ACTIONS
          end

          def description
            'Choose Difficulty Level'
          end

          def choice_name
            'Select difficulty level'
          end

          def choices
            DIFFICULTY_CHOICES
          end

          def blocks?
            true
          end

          def process_choose(action)
            difficulty = action.choice
            @game.assign_difficulty_level(difficulty)
            @log << "#{action.entity.name} selected difficulty level: #{DIFFICULTY_CHOICES[difficulty]}"
            @log << "Tile lay and skip corporation costs are #{@game.format_currency(@game.difficulty_level_value)}"
            pass!
          end

          def skip!
            # Auto-select normal if no choice is made
            @game.assign_difficulty_level('normal')
            @log << 'Auto-selected difficulty level: Normal'
            pass!
          end
        end
      end
    end
  end
end
