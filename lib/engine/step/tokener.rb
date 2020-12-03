# frozen_string_literal: true

require_relative 'base'
require_relative '../token'

module Engine
  module Step
    module Tokener
      def can_place_token?(entity)
        current_entity == entity &&
          (tokens = available_tokens(entity)).any? &&
          min_token_price(tokens) <= buying_power(entity) &&
          @game.graph.can_token?(entity)
      end

      def available_tokens(entity)
        token_holder = entity.company? ? entity.owner : entity
        token_holder.tokens_by_type
      end

      def can_replace_token?(_entity, _token)
        false
      end

      def place_token(entity, city, token, teleport: false, special_ability: nil)
        hex = city.hex
        if !@game.loading && !teleport && !@game.graph.connected_nodes(entity)[city]
          city_string = hex.tile.cities.size > 1 ? " city #{city.index}" : ''
          @game.game_error("Cannot place token on #{hex.name}#{city_string} because it is not connected")
        end

        if special_ability&.city && (special_ability.city != city.index)
          @game.game_error("#{special_ability.owner.name} can only place token on #{hex.name} city "\
                           "#{special_ability.city}, not on city #{city.index}")
        end

        @game.game_error('Token is already used') if token.used

        token, ability = adjust_token_price_ability!(entity, token, hex, city)
        tokener = entity.name
        if ability
          tokener = "#{entity.name} (#{ability.owner.sym})" if ability.owner != entity
          entity.remove_ability(ability)
        end

        free = !token.price.positive?
        city.place_token(entity, token, free: free, cheater: special_ability&.cheater)
        unless free
          entity.spend(token.price, @game.bank)
          price_log = " for #{@game.format_currency(token.price)}"
        end

        case token.type
        when :neutral
          entity.tokens.delete(token)
          token.corporation.tokens << token
          @log << "#{tokener} places a neutral token on #{hex.name}#{price_log}"
        else
          @log << "#{tokener} places a token on #{hex.name} (#{hex.location_name})#{price_log}"
        end

        @game.graph.clear
      end

      def min_token_price(tokens)
        token = tokens.first
        return 0 if @round.teleported?(token.corporation)

        prices = tokens.map(&:price)

        token.corporation.abilities(:token) do |ability, _|
          prices << ability.price(token)
          prices << ability.teleport_price
        end

        prices.compact.min
      end

      def adjust_token_price_ability!(entity, token, hex, city)
        if (teleport = @round.teleported?(entity))
          token.price = 0
          return [token, teleport]
        end

        entity.abilities(:token) do |ability, _|
          next if ability.hexes.any? && !ability.hexes.include?(hex.id)
          next if ability.city && ability.city != city.index

          # check if this is correct or should be a corporation
          if ability.extra
            token = Engine::Token.new(entity)
          elsif ability.neutral
            neutral_corp = Corporation.new(
              sym: 'N',
              name: 'Neutral',
              logo: 'open_city',
              tokens: [0],
            )
            token = Engine::Token.new(neutral_corp, type: :neutral)
          end

          token.price = ability.teleport_price if ability.teleport_price
          token.price = ability.price(token) if @game.graph.reachable_hexes(entity)[hex]
          return [token, ability]
        end

        [token, nil]
      end
    end
  end
end
