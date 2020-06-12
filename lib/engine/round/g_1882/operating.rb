# frozen_string_literal: true

require_relative '../operating'

module Engine
  module Round
    module G1882
      class Operating < Operating
        def place_token(action)
          entity = action.entity
          token = action.token || entity.next_token
          super(action)

          return unless token.corporation != entity

          entity.tokens.delete(token)
          token.corporation.tokens << token
          @log.pop
          @log << "#{entity.name} places a neutral token on #{action.city.hex.name}"
        end
      end
    end
  end
end
