# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G18FL
      class Token < Token
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

          cost = token.price * @game.graph.distance_to_station(entity, hex)
          raise GameError, "#{entity.name} cannot afford "\
                "#{@game.format_currency(cost)} cost to lay hotel" if entity.cash < cost

          @game.log << "#{entity.name} places a hotel on #{hex.name} for #{@game.format_currency(cost)}"
          entity.spend(cost, @game.bank)

          entity.tokens.delete(token)
          hex.tile.icons << Part::Icon.new("../logos/18_fl/#{entity.id}")
          pass!
        end

        def tokened(hex, entity)
          hex.tile.icons.any? { |i| i.name == entity.id }
        end

        def adjust_token_price_ability!(entity, token, hex, _city, _special_ability = nil)
          cost = token.price * @game.graph.distance_to_station(entity, hex)
          raise GameError, "#{entity.name} cannot afford "\
              "#{@game.format_currency(cost)} to lay token in "\
              "#{hex.tile.location_name}" if cost > entity.cash

          token.price = cost
          [token, nil]
        end
      end
    end
  end
end
