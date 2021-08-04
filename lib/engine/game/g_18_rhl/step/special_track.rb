# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative 'lay_tile_checks'

module Engine
  module Game
    module G18Rhl
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include LayTileChecks

          def abilities(entity, **_kwargs)
            return unless @game.round.active_step.respond_to?(:process_lay_tile)

            # Restrict private No2 and No4 to not be used in yellow phase
            return if @game.phase.name == '2' &&
                     (entity == @game.konzession_essen_osterath ||
                      entity == @game.trajektanstalt)

            super
          end

          def process_lay_tile(action)
            ability = abilities(action.entity)
            super

            return unless ability.type == :teleport

            @round.teleported = @game.current_entity

            # Need to keep track of ability that triggered teleport
            # as the ability does not belong to current entity, but to
            # player owned ability.
            @round.teleport_ability = ability
          end

          # Private 3 (Sailzuganlage) has all possible tiles, that can be played in all
          # hexes with mountain terrain, as candidates. The general code will let through
          # hexes that are not allowed, so we need to remove illegal upgrades.
          def potential_tiles(entity, hex)
            return [] unless (tile_ability = abilities(entity))

            candidates = super
            return candidates if candidates.empty? || tile_ability.owner != @game.seilzuganlage

            potentials = @game.all_potential_upgrades(hex.tile).map(&:name)
            candidates.select { |t| @game.upgrades_to?(hex.tile, t) && potentials.include?(t.name) }
          end
        end
      end
    end
  end
end
