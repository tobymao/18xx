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

          def update_token!(action, entity, tile, old_tile)
            cities = tile.cities
            tokens = cities.flat_map(&:tokens).compact

            if old_tile.name == @game.class::PARIS_HEX && old_tile.paths.empty?
              plm_token = tokens.find { |t| t.corporation.id == 'PLM' }
              plm_token.move!(cities[0])
              @game.graph.clear
            elsif @game.class::GREEN_CITY_TILES.include?(old_tile.name) && !tokens.empty?
              puts '0'
              tokens.each do |token|
                actor = entity.company? ? entity.owner : entity
                puts 'a'
                if token.corporation == actor
                  puts 'b'
                  @round.pending_tokens << {
                    entity: actor,
                    hexes: [action.hex],
                    token: token,
                  }
                  @log << "#{actor.name} must choose city for token"
                end

                token.remove!
              end
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
