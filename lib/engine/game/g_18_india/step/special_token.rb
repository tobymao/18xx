# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18India
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          # P5 (Danish EIC) has when: ['token', 'special_token'], which routes
          # through ability_blocking_step to find the active step type.  That
          # check fails when the Token step is inactive (e.g. Nepal city is fully
          # reserved, so can_token? returns false for regular tokens).  P5's
          # availability should depend only on whether it's the owning corp's OR
          # turn and P5 hasn't been used — not on whether a regular token slot
          # exists.  Override ability() to check that directly.
          def ability(entity)
            return unless entity&.company?
            return unless @round.operating?
            return unless @round.current_operator == @game.token_owner(entity)

            @game.abilities(entity, :token, time: 'any') { |a, _| return a if a.special_only }
            @game.abilities(entity, :token) { |a, _| return a }
          end

          # Tokener#adjust_token_price_ability! handles :teleport directly but
          # re-fetches :token type via @game.abilities(), which fails our timing
          # check when the Token step is inactive.  Mirror the teleport path.
          def adjust_token_price_ability!(entity, token, hex, city, special_ability: nil)
            if special_ability&.type == :token && special_ability.special_only
              token.price = if special_ability.teleport_price
                              [token.price, special_ability.teleport_price].min
                            else
                              [token.price - special_ability.discount.to_i, 0].max
                            end
              return [token, special_ability]
            end

            super
          end
        end
      end
    end
  end
end
