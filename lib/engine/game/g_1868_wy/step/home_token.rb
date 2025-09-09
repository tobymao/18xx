# frozen_string_literal: true

require_relative '../../../step/home_token'

module Engine
  module Game
    module G1868WY
      module Step
        class HomeToken < Engine::Step::HomeToken
          def process_place_token(action)
            corp = token.corporation

            if @game.tokenless_dpr?(corp)
              corp.coordinates = action.city.hex.id
              if corp.floated?
                super
              else
                action.city.tile.add_reservation!(token.corporation, action.city)
                @round.pending_tokens.shift
                @log << "#{corp.name} reserves #{action.city.hex.id} (#{action.city.tile.location_name}) for its home token"
              end
            else
              super
            end
          end
        end
      end
    end
  end
end
