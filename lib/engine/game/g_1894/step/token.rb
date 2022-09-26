# frozen_string_literal: true

require_relative '../../../step/token'

module Engine
  module Game
    module G1894
      module Step
        class Token < Engine::Step::Token
          def actions(entity)
            return [] if @game.skip_track_and_token

            super
          end

          def place_token(entity, city, token, connected: true, extra_action: false, special_ability: nil)
            if city.hex.name == Engine::Game::G1894::Game::LONDON_HEX
              raise GameError,
                    "#{city.hex.location_name} may not be tokened"
            end

            if city.hex.name == @game.saved_tokens_hex&.name
              if @game.saved_tokens&.size == 2
                raise GameError,
                      "#{city.hex.location_name} may not be tokened until removed tokens are placed again"
              end

              if @game.saved_tokens&.size == 1 && city.tile.reservations.any?
                raise GameError,
                      "#{city.hex.location_name} may not be tokened until the removed token is placed again as \
                        the tile is reserved by a corporation"
              end
            end

            super
          end

          def process_place_token(action)
            super

            tile = action.city.hex.tile

            return if Engine::Game::G1894::Game::BROWN_CITY_TILES.include?(tile.name) && !tile.reservations.empty?

            # If only one city left, move the reservation there
            reservation = tile.reservations.first

            tile.cities.each do |city|
              next unless city.tokenable?(reservation.corporation)

              city.add_reservation!(reservation.corporation)
              tile.reservations.clear
              break
            end
          end
        end
      end
    end
  end
end
