# frozen_string_literal: true

require_relative '../../../step/buy_company'
require_relative 'choose_ability_on_or'

module Engine
  module Game
    module G18ZOO
      module Step
        class BuyOrUsePowerOnOr < Engine::Step::Base
          include Engine::Game::G18ZOO::ChooseAbilityOnOr

          ACTIONS = %w[choose_ability].freeze

          def actions(entity)
            return [] if @round.president_helped

            # TODO: change to something like this: @game.abilities(entity, :assign_hexes) ||
            return can_choose_ability?(entity) ? ACTIONS : [] if entity.company?
            return [] unless blocks?

            actions = []
            actions << 'choose_ability' if can_choose_any_ability_on_any_step?(entity)
            actions << 'pass' unless actions.empty?
            actions.uniq
          end

          def blocks?
            @opts[:blocks]
          end

          def description
            'Buy / use powers'
          end

          def pass_description
            @acted ? 'Done (Buy Powers)' : 'Skip (Buy Powers)'
          end

          private

          def can_choose_ability?(company)
            entity = @game.current_entity
            return false if entity.player?

            return true if can_choose_ability_on_any_step(entity, company)

            false
          end
        end
      end
    end
  end
end
