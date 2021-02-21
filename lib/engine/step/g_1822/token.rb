# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G1822
      class Token < Token
        def available_tokens(entity)
          entity.tokens_by_type.reject { |t| t.type == :destination }
        end

        def process_place_token(action)
          entity = action.entity
          city = action.city

          if entity.corporation? && entity.type == :major
            destination_token = entity.find_token_by_type(:destination)
            if destination_token && city.hex.name == @game.class::DESTINATIONS[entity.id]
              raise GameError, "Can't place token on #{city.hex.name}, that hex is reserved for destination token. "\
                               'Please undo this move and place your destination token'
            end

            if city.tokened_by?(entity)
              hex = city.hex
              city_string = city.hex.tile.cities.size > 1 ? " city #{city.index}" : ''
              raise GameError, "Can't place token on #{hex.name}#{city_string} because #{entity.id} cant have 2 "\
                             'tokens in the same city'
            end
          end

          check_tokenable = city.hex.name != @game.class::LONDON_HEX
          place_token(entity, action.city, action.token, check_tokenable: check_tokenable)
          pass!
        end
      end
    end
  end
end
