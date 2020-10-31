# frozen_string_literal: true

require_relative '../token'

module Engine
  module Step
    module G1828
      class Token < Token
        VA_COALFIELDS_HEX = 'K11'
        
        def place_token(entity, city, token, teleport: false)
          if city.hex.name == VA_COALFIELDS_HEX
            @game.game_error("#{city.hex.location_name} may not be tokened")
          else
            super
          end
        end
      end
    end
  end
end
