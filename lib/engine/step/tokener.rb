# frozen_string_literal: true

require_relative 'base'
require_relative '../token'

module Engine
  module Step
    module Tokener
      def can_place_token?(entity)
        current_entity == entity &&
          (token = entity.next_token) &&
          min_token_price(token) <= entity.cash &&
          @game.graph.can_token?(entity)
      end

      def available_tokens
        current_entity.tokens_by_type
      end

      def place_token(entity, city, token, teleport: false)
        hex = city.hex
        if !@game.loading && !teleport && !@game.graph.connected_nodes(entity)[city]
          raise GameError, "Cannot place token on #{hex.name} because it is not connected"
        end

        raise GameError, 'Token is already used' if token.used

        token, ability_type = adjust_token_price_ability!(entity, token, hex)
        entity.remove_ability(ability_type)
        free = !token.price.positive?
        city.place_token(entity, token, free: free)
        unless free
          entity.spend(token.price, @game.bank)
          price_log = " for #{@game.format_currency(token.price)}"
        end

        case token.type
        when :neutral
          entity.tokens.delete(token)
          token.corporation.tokens << token
          @log << "#{entity.name} places a neutral token on #{city.hex.name}#{price_log}"
        else
          @log << "#{entity.name} places a token on #{city.hex.name}#{price_log}"
        end

        @game.graph.clear
      end

      def min_token_price(token)
        return 0 if teleported?(token.corporation)

        prices = [token.price]

        token.corporation.abilities(:token) do |ability, _|
          prices << ability.price
          prices << ability.teleport_price
        end

        prices.compact.min
      end

      def teleported?(entity)
        entity.abilities(:teleport).any?(&:used?)
      end

      def adjust_token_price_ability!(entity, token, hex)
        if teleported?(entity)
          token.price = 0
          return [token, :teleport]
        end

        entity.abilities(:token) do |ability, _|
          next unless ability.hexes.include?(hex.id)

          # check if this is correct or should be a corporation
          token = Engine::Token.new(entity) if ability.extra
          token.price = ability.teleport_price if ability.teleport_price
          token.price = ability.price if @game.graph.reachable_hexes(entity)[hex]
          return [token, :token]
        end

        [token, nil]
      end
    end
  end
end
