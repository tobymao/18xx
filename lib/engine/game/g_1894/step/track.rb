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
              @game.save_tokens(tokens, hex)

              tokens.each do |token|
                token.remove!
              end
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
            elsif saved_tokens
              acting_corporation_token = saved_tokens.find { |t| t.corporation == entity}

              return unless acting_corporation_token

              @round.pending_tokens << {
                entity: entity,
                hexes: [action.hex],
                token: acting_corporation_token,
              }

              @log << "#{entity.name} must choose city for token"
              
              saved_tokens.delete(acting_corporation_token)
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
