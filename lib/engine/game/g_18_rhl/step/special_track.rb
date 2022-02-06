# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'lay_tile_checks'

module Engine
  module Game
    module G18Rhl
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include LayTileChecks

          def abilities(entity, **kwargs, &block)
            return if !entity.company? ||
                      # Do not allow any tile lay if tokening has been used
                      @round.tokened ||
                      # Do not allow special tile lay after train buys (to avoid exploits)
                      @round.bought_trains.include?(@game.current_entity) ||
                      # Restrict private No2 and No4 (and No1 in Ratingen variant) to not be used in yellow phase
                      (@game.phase.name == '2' &&
                       (entity == @game.konzession_essen_osterath ||
                        entity == @game.trajektanstalt ||
                        entity == @game.angertalbahn))

            %i[tile_lay teleport].each do |type|
              ability = @game.abilities(
                              entity,
                              type,
                              time: :owning_player_or_turn,
                              **kwargs,
                              &block
                            )
              return ability if ability && !ability.used?
            end
            nil
          end

          def legal_tile_rotations(entity, hex, tile)
            return [1] if lay_of_osterath_tile?(entity, hex, tile)

            super
          end

          def legal_tile_rotation?(entity, hex, tile)
            return true if lay_of_osterath_tile?(entity, hex, tile)

            super
          end

          def get_tile_lay(_entity)
            # Base code caused a crash for 18Rhl so this solves it.
            { lay: true, upgrade: true, cost: 0, upgrade_cost: 0, cannot_reuse_same_hex: false }
          end

          def process_lay_tile(action)
            if action.entity == @game.trajektanstalt && action.tile.color == :brown
              # Private 4 can only be used to upgrade to green
              raise GameError, "#{@game.trajektanstalt.name} cannot upgrade to brown tiles"
            end

            ability = abilities(action.entity)

            super

            return unless ability.type == :teleport

            @round.teleported = @game.current_entity

            # Need to keep track of ability that triggered teleport
            # as the ability does not belong to current entity, but to
            # player owned ability.
            @round.teleport_ability = ability

            # Set location name to Osterath to make the name appear when tokening city in tile
            @game.osterath_tile.hex.location_name = 'Osterath' if action.tile == @game.osterath_tile
          end

          # Private 3 (Sailzuganlage) has all possible tiles, that can be played in all
          # hexes with mountain terrain, as candidates. The general code will let through
          # hexes that are not allowed, so we need to remove illegal upgrades.
          def potential_tiles(entity, hex)
            return [] unless (tile_ability = abilities(entity))

            candidates = super
            candidates << @game.osterath_tile if hex.name == 'E8' && entity == @game.konzession_essen_osterath
            return candidates if candidates.empty? || tile_ability.owner != @game.seilzuganlage

            potentials = @game.all_potential_upgrades(hex.tile).map(&:name)
            candidates.select { |t| @game.upgrades_to?(hex.tile, t) && potentials.include?(t.name) }
          end

          private

          def lay_of_osterath_tile?(entity, hex, tile)
            hex.name == 'E8' && entity == @game.konzession_essen_osterath && tile == @game.osterath_tile
          end
        end
      end
    end
  end
end
