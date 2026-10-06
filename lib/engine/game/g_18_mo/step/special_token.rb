# frozen_string_literal: true

require_relative '../../../step/special_token'

module Engine
  module Game
    module G18MO
      module Step
        class SpecialToken < Engine::Step::SpecialToken
          def process_place_token(action)
            entity = action.entity

            hex = action.city.hex
            city_string = hex.tile.cities.size > 1 ? " city #{action.city.index}" : ''
            raise GameError, "Cannot place token on #{hex.name}#{city_string}" unless available_hex(entity, hex)

            ability = ability(entity)
            check_connected = ability.type == :token && !ability.teleport_price

            place_token(
              @game.token_owner(entity),
              action.city,
              action.token,
              connected: check_connected,
              special_ability: ability,
            )

            teleport_complete if @round.teleported
            @game.remove_teleport_destination(entity, action.city)
          end

          def available_hex(entity, hex)
            ability = ability(entity)
            return unless ability

            if ability.type == :token && ability.hexes.empty?
              return true if entity.owner.all_abilities.any? { |a| a.type == :token && a.hexes.include?(hex.id) }

              return @game.token_graph_for_entity(entity.owner).reachable_hexes(entity.owner)[hex]
            end

            super
          end

          def ability(entity)
            return super unless entity&.company?

            @game.abilities(entity, :token) do |ability, _|
              next if ability.owner_type == 'corporation' && !ability.discount

              return ability
            end

            @game.abilities(entity, :teleport) do |ability, _|
              return ability if ability.used?
            end

            nil
          end
        end
      end
    end
  end
end
