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

          def process_lay_tile(action)
            ability = abilities(action.entity)
            super
            return unless action.entity == @game.wlg_company
            return if @game.western_hex?(action.hex)
            return unless ability

            ability.hexes = @game.class::WEST_RIVER_HEXES
          end
        end
      end
    end
  end
end
