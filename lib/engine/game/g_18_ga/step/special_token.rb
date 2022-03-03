# frozen_string_literal: true

require_relative '../../../step/special_token'
require_relative 'only_one_token_per_round'

module Engine
  module Game
    module G18GA
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def actions(entity)
            return [] if already_tokened_this_round?(entity)
            return ['place_token'] if ability(entity) &&
              remaining_token_ability?(entity) &&
              @game.round.active_step.respond_to?(:process_place_token)

            []
          end

          def ability(entity)
            ability = super

            ability if ability && entity_corporation(entity) == @game.round.current_entity
          end

          def process_place_token(action)
            target = action.city.hex.name
            allowed = ability(action.entity).hexes
            raise GameError, "#{target} not allowed for token. Only allowed: #{allowed}." unless allowed.include?(target)

            super

            @game.remove_icon_from_waycross unless @game.abilities(@game.p3_company, :token)&.count&.positive?
          end

          include OnlyOneTokenPerRound
        end
      end
    end
  end
end
