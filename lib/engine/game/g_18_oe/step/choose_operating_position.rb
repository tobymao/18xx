# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18OE
      module Step
        class ChooseOperatingPosition < Engine::Step::Base
          ACTIONS = %w[choose].freeze

          def actions(entity)
            entity && entity == current_entity ? ACTIONS : []
          end

          def active_entities
            return [] if !@round.entity_index.zero? || @round.operating_position

            ability = @game.minor_c_ability
            entity = ability&.owner
            return [] unless @round.entities.include?(entity)
            return [] unless %i[minor major].include?(entity.type)
            return [] if entity.closed? || !entity.owner&.player? || !entity.abilities.include?(ability)

            [entity]
          end

          def description
            'Choose Operating Position'
          end

          def choice_name
            "#{current_entity.name}'s operating position"
          end

          def choices
            { 'first' => 'First', 'normal' => 'Normal', 'last' => 'Last' }
          end

          def process_choose(action)
            raise GameError, 'Cannot choose operating position' unless actions(action.entity).include?('choose')
            raise GameError, "Invalid operating position: #{action.choice}" unless choices.key?(action.choice)

            @log << "#{action.entity.name} chooses #{action.choice} in its operating group"
            pass!
            @round.choose_operating_position!(action.entity, action.choice)
          end

          def log_skip(_entity); end
        end
      end
    end
  end
end
