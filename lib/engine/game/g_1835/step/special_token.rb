# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1835
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def available_tokens(entity)
            return available_tokens(@round.current_operator) if tokening_company?(entity)
            return [] unless entity.corporation?

            entity.tokens_by_type
          end

          def adjust_token_price_ability!(entity, token, hex, city, special_ability: nil)
            # If a tokening company with timing owning_player_or_turn is used, this method is called with 'entity' being
            # a player. The super implementation will eventually ask for all_abilities of this entity, which a player
            # does not have. We therefore return the token here as is, because we want to avoid the game from crashing
            # and don't want to adjust anything anyway.
            return [token, nil] if entity.player?

            super
          end

          private

          def tokening_company?(entity)
            entity.company? && entity.abilities.any? { |a| a.type == :token && a.when.include?('owning_player_or_turn') }
          end
        end
      end
    end
  end
end
