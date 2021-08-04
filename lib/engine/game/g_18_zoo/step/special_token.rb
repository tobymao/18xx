# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def available_hex(entity, hex)
            return unless entity.company?
            return unless entity.owner&.corporation?
            return if entity == @game.on_a_diet && !available_hex_for_on_a_diet?(entity, hex)
            return if entity == @game.that_s_mine && !available_hex_for_that_s_mine?(entity, hex)

            super
          end

          private

          def available_hex_for_on_a_diet?(entity, hex)
            @game.graph.reachable_hexes(entity.owner)[hex] &&
              !hex.tile.cities.empty? &&
              !hex.tile.cities.first.tokened_by?(entity.owner)
          end

          def available_hex_for_that_s_mine?(entity, hex)
            hex.tile.cities&.first&.reserved_by?(entity.owner) &&
              @game.graph.reachable_hexes(entity.owner)[hex] &&
              entity.owner.unplaced_tokens.first.price <= buying_power(entity.owner)
          end
        end
      end
    end
  end
end
