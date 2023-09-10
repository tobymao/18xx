# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../../../step/token_merger'
require_relative '../../g_1822/step/minor_acquisition'

module Engine
  module Game
    module G1822Africa
      module Step
        class MinorAcquisition < Engine::Game::G1822::Step::MinorAcquisition
          def actions(entity)
            actions = super

            actions << 'choose_ability' if !choices_ability(entity).empty? && !actions.include?('choose_ability')

            actions
          end

          def choices_ability(entity)
            return {} unless entity.company?

            @game.company_choices(entity, :acquire_minor)
          end

          def process_choose_ability(action)
            @game.company_made_choice(action.entity, action.choice, :acquire_minor)
          end

          def can_acquire?(entity)
            return false if !entity.corporation? || (entity.corporation? && entity.type != :major)

            !potentially_mergeable(entity).empty?
          end

          def potentially_mergeable(entity)
            # Mergable ignoring connections
            minors = @game.corporations.select do |minor|
              minor.type == :minor && minor.floated? && !pay_choices(entity, minor).empty?
            end

            if @game.phase.status.include?('can_acquire_minor_bidbox')
              bidbox_minors = @game.bidbox.select { |c| @game.minor?(c) }
              available_minors = bidbox_minors.map { |c| @game.find_corporation(c) }.reject do |minor|
                pay_choices(entity, minor).empty?
              end
              minors.concat(available_minors) if available_minors
            end

            minors
          end
        end
      end
    end
  end
end
