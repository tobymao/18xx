# frozen_string_literal: true

require_relative 'base'
require_relative '../token'

module Engine
  module Step
    module Tokener
      def round_state
        {
          tokened: false,
        }
      end

      def setup
        @round.tokened = false
      end

      def can_place_token?(entity)
        current_entity == entity &&
          !@round.tokened &&
          !(tokens = available_tokens(entity)).empty? &&
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

      def place_token(entity, city, token, connected: true, extra: false, special_ability: nil, check_tokenable: true)
        hex = city.hex
        extra ||= special_ability.extra if special_ability&.type == :token

        if !@game.loading && connected && !@game.graph.connected_nodes(entity)[city]
          city_string = hex.tile.cities.size > 1 ? " city #{city.index}" : ''
          raise GameError, "Cannot place token on #{hex.name}#{city_string} because it is not connected"
        end

        if special_ability&.type == :token && special_ability.city && special_ability.city != city.index
          raise GameError, "#{special_ability.owner.name} can only place token on #{hex.name} city "\
                           "#{special_ability.city}, not on city #{city.index}"
        end

        if special_ability&.type == :teleport &&
           !special_ability.hexes.empty? &&
           !special_ability.hexes.include?(hex.id)
          raise GameError, "#{special_ability.owner.name} cannot place token in "\
                           "#{hex.name} (#{hex.location_name}) with teleport"
        end

        raise GameError, 'Token already placed this turn' if !extra && @round.tokened

        token, ability = adjust_token_price_ability!(entity, token, hex, city, special_ability: special_ability)
        tokener = entity.name
        if ability
          tokener += " (#{ability.owner.sym})" if ability.owner != entity
          entity.remove_ability(ability)
        end

        raise GameError, 'Token is already used' if token.used

        free = !token.price.positive?
        if ability&.type == :token
          cheater = ability.cheater
          extra_slot = ability.extra_slot
        end
        city.place_token(entity, token, free: free, check_tokenable: check_tokenable,
                                        cheater: cheater, extra_slot: extra_slot)
        unless free
          pay_token_cost(entity, token.price)
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

        @round.tokened = true unless extra
        @game.graph.clear
      end

      def pay_token_cost(entity, cost)
        entity.spend(cost, @game.bank)
      end

      def min_token_price(tokens)
        token = tokens.first
        prices = tokens.map(&:price)

        @game.abilities(token.corporation, :token) do |ability, _|
          prices << ability.price(token)
          prices << ability.teleport_price
        end

        prices.compact.min
      end

      def adjust_token_price_ability!(entity, token, hex, city, special_ability: nil)
        if special_ability&.type == :teleport
          token.price = 0
          return [token, special_ability]
        end

        # TODO: special_ability token here
        @game.abilities(entity, :token) do |ability, _|
          next if ability.special_only && ability != special_ability
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
