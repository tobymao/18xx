# frozen_string_literal: true

require_relative 'base'

module Engine
  module Step
    class Token < Base
      ACTIONS = %w[place_token pass].freeze

      def actions(entity)
        return [] if current_entity != entity ||
          !(token = entity.next_token) ||
          min_token_price(token) > entity.cash ||
          !@game.graph.can_token?(entity)

        ACTIONS
      end

      def description
        'Lay Track'
      end

      def pass_description
        'Skip (Track)'
      end

      def sequential?
        true
      end

      def process_place_token(action)
        entity = action.entity
        hex = action.city.hex

        if !@game.loading && @step != :home_token && !connected_nodes[action.city]
          raise GameError, "Cannot place token on #{hex.name} because it is not connected"
        end

        token = action.token
        raise GameError, 'Token is already used' if token.used

        token, ability_type = adjust_token_price_ability!(entity, token, hex)
        entity.remove_ability(ability_type)
        free = !token.price.positive?
        action.city.place_token(entity, token, free: free)
        unless free
          entity.spend(token.price, @game.bank)
          price_log = " for #{@game.format_currency(token.price)}"
        end

        case token.type
        when :neutral
          entity.tokens.delete(token)
          token.corporation.tokens << token
          @log << "#{entity.name} places a neutral token on #{action.city.hex.name}#{price_log}"
        else
          @log << "#{entity.name} places a token on #{action.city.hex.name}#{price_log}"
        end

        @game.graph.clear
        pass!
      end

      def min_token_price(token)
        return 0 if @teleported

        prices = [token.price]

        token.corporation.abilities(:token) do |ability, _|
          prices << ability.price
          prices << ability.teleport_price
        end

        prices.compact.min
      end

      def adjust_token_price_ability!(entity, token, hex)
        if @teleported
          token.price = 0
          return [token, :teleport]
        end

        entity.abilities(:token) do |ability, _|
          next unless ability.hexes.include?(hex.id)

          # check if this is correct or should be a corporation
          token = Token.new(entity) if ability.extra
          token.price = ability.teleport_price if ability.teleport_price
          token.price = ability.price if reachable_hexes[hex]
          return [token, :token]
        end

        [token, nil]
      end
    end
  end
end
