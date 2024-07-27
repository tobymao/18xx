# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Track < Engine::Step::Track
          MINOR_TILE_COLORS = %w[yellow green].freeze

          def actions(entity)
            return [] if entity.receivership?

            super
          end

          def potential_tiles(entity, hex)
            colors = @game.phase.tiles
            colors &= MINOR_TILE_COLORS if entity.type == :minor
            @game.tiles
                 .select { |tile| colors.include?(tile.color) }
                 .uniq(&:name)
                 .select { |tile| @game.upgrades_to?(hex.tile, tile) }
          end

          def legal_tile_rotation?(entity_or_entities, hex, tile)
            # Special case for the Ruhr green tile, which loses a town.
            return tile.rotation.zero? if hex.name == 'B16' && tile.name == 'X11'

            # Special case for the green Dunkerque tile. This must connect to
            # the second port exit (to hex F2).
            return super && tile.exits.include?(2) if hex.name == 'G3' && tile.color == :green

            super
          end

          def process_lay_tile(action)
            super
            @game.after_lay_tile(action.hex, action.tile, action.entity)
          end

          def update_token!(action, entity, tile, old_tile)
            super

            # Might need to remove a token if two cities have joined together.
            return if !tile.cities.one? || old_tile.cities.size != 2

            corp_tokens = tile.cities.first.tokens.compact.group_by(&:corporation)
            corp_tokens.each do |corporation, tokens|
              next if tokens.one?

              # This can only happen in Amsterdam, Basel, Frankfurt-am-Main and
              # Rotterdam. These all have two slots in brown, so there's never
              # more than one token to remove.
              tokens.last.remove!
              @game.log << "#{corporation.id} token removed from " \
                           "#{tile.hex.name} (#{tile.hex.location_name})."
            end
          end
        end
      end
    end
  end
end
