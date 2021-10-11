# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G18CO
      module Step
        class HomeToken < Engine::Step::HomeToken
          def active?
            pending_entity && multiple_home_slot(pending_entity)
          end

          def multiple_home_slot(entity)
            return false unless entity.corporation?

            tile = @game.hex_by_id(entity.coordinates).tile
            city = tile.cities.find { |c| c.reserved_by?(entity) }
            return tile.available_slot? unless city

            place_token(
              pending_entity,
              city,
              token,
              connected: false,
            )
            @round.pending_tokens.shift

            false
          end
        end
      end
    end
  end
end
