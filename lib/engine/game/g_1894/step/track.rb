# frozen_string_literal: true

require_relative 'tracker'

module Engine
  module Game
    module G1894
      module Step
        class Track < Engine::Step::Track
          include Engine::Game::G1894::Tracker

          def actions(entity)
            return [] if @game.skip_track_and_token

            super
          end

          def legal_tile_rotation?(_entity, hex, tile)
            return super if hex.id != @game.class::PARIS_HEX || hex.tile.color != :green

            plm_in_city_0 = true if hex.tile.cities[0].reserved_by?(@game.plm) || hex.tile.cities[0].tokened_by?(@game.plm)

            if tile.name == 'X7' || plm_in_city_0
              return true if tile.rotation == hex.tile.rotation
            else
              return true if tile.rotation == hex.tile.rotation + 3
            end
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            hex = action.hex
            old_tile = hex.tile
            new_tile = action.tile

            if @game.class::BROWN_CITY_TILES.include?(new_tile.name)
              # The city splits into two cities, so the reservation has to be for the whole hex
              reservation = old_tile.cities.first.reservations.compact.first
              if reservation
                old_tile.cities.first.remove_all_reservations!
                old_tile.add_reservation!(reservation.corporation, nil, reserve_city=false)
              end

              tokens =  old_tile.cities.flat_map(&:tokens).compact
              tokens_to_save = []
              tokens.each do |token|
                token.price = 0
                tokens_to_save << {
                  entity: token.corporation,
                  hexes: [hex],
                  token: token,
                }
              end
              @game.save_tokens(tokens_to_save)
              @game.save_tokens_hex(hex)

              tokens.each { |t| t.remove! }
            end
            super
          end

          def update_token!(action, entity, tile, old_tile)
            cities = tile.cities
            tokens = cities.flat_map(&:tokens).compact
            saved_tokens = @game.saved_tokens

            if old_tile.name == @game.class::PARIS_HEX && old_tile.paths.empty?
              plm_token = tokens.find { |t| t.corporation.id == 'PLM' }
              
              return unless plm_token

              plm_token.move!(cities.first)
              @game.graph.clear
              
            elsif saved_tokens.any?
              token = saved_tokens.find { |t| t[:entity] == entity}
              return unless token

              @round.pending_tokens << {
                entity: token[:entity],
                hexes: token[:hexes],
                token: token[:token]
              }
              @log << "#{entity.name} must choose city for token"
              saved_tokens.delete(token)
              @game.save_tokens(saved_tokens)
              @game.graph.clear
            else
              super
            end
          end
        end
      end
    end
  end
end
