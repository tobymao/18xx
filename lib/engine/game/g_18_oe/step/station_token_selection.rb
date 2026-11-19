# frozen_string_literal: true

require_relative 'validated_token_cost'

module Engine
  module Game
    module G18OE
      module Step
        module StationTokenSelection
          include ValidatedTokenCost

          def available_tokens(entity)
            entity.tokens.select { |token| available_station_token?(entity, token) }.uniq(&:price)
          end

          def selectable_token_choices(entity, city)
            fee = station_token_fee(entity, city)
            available_tokens(entity).map do |token|
              { token: token, index: entity.tokens.index(token), cost: token.price + fee }
            end
          end

          private

          def available_station_token?(entity, token)
            token && !token.used && token.type == :normal && token.corporation == entity
          end

          def selected_token(action)
            index = action.token_index
            return action.token if index.nil?

            entity = action.entity
            return if !index.is_a?(Integer) || index.negative? || index >= entity.tokens.size

            entity.tokens[index]
          end
        end
      end
    end
  end
end
