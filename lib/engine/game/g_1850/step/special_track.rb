# frozen_string_literal: true

require_relative '../../../step/special_track'

module Engine
  module Game
    module G1850
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          def actions(entity)
            return [] unless can_use_special_track?(entity)

            super
          end

          def can_use_special_track?(entity)
            @round.steps.find { |step| step.is_a?(Track) }.acted || entity == @game.river_company
          end

          def hex_neighbors(entity, hex)
            return super if entity != @game.wlg_company ||
                            @game.western_hex?(hex) ||
                            !@game.wlg_anywhere_available?

            # Allow the one non-western use while it hasn't been consumed yet
            ability = abilities(entity)
            return unless ability

            operator = entity.owner.corporation? ? entity.owner : @game.current_entity
            return if ability.reachable && !@game.graph.connected_hexes(operator)[hex]

            @game.hex_by_id(hex.id).neighbors.keys
          end

          def process_lay_tile(action)
            return super if action.entity != @game.wlg_company ||
                            @game.western_hex?(action.hex) ||
                            !@game.wlg_anywhere_available?

            # Temporarily clear the hex restriction so the server-side ability
            # check in lay_tile passes for the one allowed non-western use
            ability = abilities(action.entity)
            ability.hexes = []
            super
            ability.hexes = @game.class::WEST_RIVER_HEXES unless ability.count&.zero?
          end
        end
      end
    end
  end
end
