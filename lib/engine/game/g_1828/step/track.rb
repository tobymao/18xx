# frozen_string_literal: true

require_relative '../../../step/track'
require_relative 'acquire_va_tunnel_coal_marker'

module Engine
  module Game
    module G1828
      module Step
        class Track < Engine::Step::Track
          include AcquireVaTunnelCoalMarker

          def update_token!(action, entity, tile, old_tile)
            if action.hex.id == 'E15'
              # When track is first laid on E15, trigger Erie to place its home token if already floated
              if old_tile.paths.empty? && !tile.paths.empty?
                erie = @game.corporation_by_id('ERIE')
                if erie && !erie.closed? && erie.floated? && !erie.tokens.first&.used &&
                    @round.pending_tokens.none? { |p| p[:entity] == erie }
                  @round.pending_tokens << {
                    entity: erie,
                    hexes: [action.hex],
                    token: erie.find_token_by_type,
                  }
                  @log << "#{erie.name} must choose city for home token"
                end
              end

              if (token = tile.cities.flat_map(&:tokens).find(&:itself))
                # If there are blocking tokens in both cities, no decisions to be made
                return if @game.blocking_token?(token)

                # Otherwise, the token owner gets to decide the token location
                entity = token.corporation
              end
            end

            super(action, entity, tile, old_tile)
          end
        end
      end
    end
  end
end
