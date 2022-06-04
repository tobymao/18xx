# frozen_string_literal: true

require_relative 'tracker'

module Engine
  module Game
    module G1894
      module Step
        class Track < Engine::Step::Track
          include Engine::Game::G1894::Tracker

          def legal_tile_rotation?(_entity, hex, tile)
            if hex.id == @game.class::PARIS_HEX && hex.tile.color == :green
              return true if tile.rotation == hex.tile.rotation
            else
              super
            end
          end

          def lay_tile(action, extra_cost: 0, entity: nil, spender: nil)
            hex = action.hex
            old_tile = hex.tile

            if @game.class::GREEN_CITY_TILES.include?(old_tile.name)
              tokens =  old_tile.cities.flat_map(&:tokens).compact
              tokens_to_save = []
              tokens.each do |token|
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
              plm_token.move!(cities[0])
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
