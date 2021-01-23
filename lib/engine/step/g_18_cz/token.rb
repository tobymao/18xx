# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G18CZ
      class Token < Token
        def process_place_token(action)
          raise GameError,
                'B9 cannot be tokened until ATE places its hometoken' if action.city.tile.hex.coordinates == 'B9' &&
                    action.city.tile.cities.all? { |city| city.tokens.compact.empty? }
          super
        end
      end
    end
  end
end
