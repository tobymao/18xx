# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18India
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def process_place_token(action)
            special_ability = ability(action.entity)

            # When a cheater token ability (e.g. Danish EIC) would bypass a tile
            # reservation block, force the token into an extra slot so that the
            # protected home-token slot (e.g. TR's Nepal slot) remains available.
            if special_ability&.cheater&.positive? &&
                 action.city.tile.token_blocked_by_reservation?(@game.token_owner(action.entity))
              special_ability.instance_variable_set(:@extra_slot, true)
            end

            super
          end
        end
      end
    end
  end
end
