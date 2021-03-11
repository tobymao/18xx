# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G18FL
      module Step
        class Token < Engine::Step::Token
          ACTIONS = %w[place_token hex_token pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] unless can_place_token?(entity)

            ACTIONS
          end

          def can_place_token?(entity)
            !@game.round.laid_token[entity] && (
              !@game.token_company.closed? ||
              (current_entity == entity &&
                !(tokens = available_tokens(entity)).empty? &&
                min_token_price(tokens) <= buying_power(entity))
            )
          end

          def process_place_token(action)
            raise GameError, "#{action.entity.name} cannot lay token now" if @game.round.laid_token[action.entity]

            raise GameError, "#{action.entity.name} cannot afford "\
                "#{@game.format_currency(action.cost)} to lay token in "\
                "#{action.city.hex.tile.location_name}" if action.cost > action.entity.cash

            action.token.price = action.cost if action.cost
            super
            @game.round.laid_token[action.entity] = true
          end

          def available_hex(entity, hex)
            @game.graph.reachable_hexes(entity)[hex]
          end

          def process_hex_token(action)
            entity = action.entity
            hex = action.hex
            token = action.token

            raise GameError, "#{hex.id} is not a town" if hex.tile.towns.empty?
            raise GameError, "#{entity.name} already has a hotel in #{hex.tile.location_name}" if tokened(hex, entity)

            cost = action.cost # We are using token_cost_override
            raise GameError, "#{entity.name} cannot afford "\
                  "#{@game.format_currency(cost)} cost to lay hotel" if cost > entity.cash

            @game.log << "#{entity.name} places a hotel on #{hex.name} for #{@game.format_currency(cost)}"
            entity.spend(cost, @game.bank)

            entity.tokens.delete(token)
            hex.tile.icons << Part::Icon.new("../logos/18_fl/#{entity.id}")
            pass!
          end

          def token_cost_override(entity, city_hex, _slot, token, _tokener)
            hex = city_hex.respond_to?(:city?) ? city_hex.hex : city_hex
            token.price * @game.graph.distance_to_station(entity, hex)
          end

          def tokened(hex, entity)
            hex.tile.icons.any? { |i| i.name == entity.id }
          end
        end
      end
    end
  end
end
