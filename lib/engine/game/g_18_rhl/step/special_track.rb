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

            # Need special handling for the Trajektanstalt teleport, as this requires
            # that the current entity gets an extra tile lay, as the teleport consumes
            # the normal one.
            @game.start_trajektanstalt_teleport if action.entity == @game.trajektanstalt
          end
        end
      end
    end
  end
end
