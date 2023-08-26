# frozen_string_literal: true

require_relative '../../g_1822/step/special_track'
require_relative 'tracker'

module Engine
  module Game
    module G1822CA
      module Step
        class SpecialTrack < G1822::Step::SpecialTrack
          include G1822CA::Tracker

          def actions(entity)
            return [] unless entity.company?

            super
          end

          def process_lay_tile(action)
            super

            # cannot lay a second yellow after using one of the P19-P20 Mountain
            # Pass privates
            @round.num_laid_track += 1 if @game.class::MOUNTAIN_PASS_COMPANIES.include?(action.entity.id)
          end
        end
      end
    end
  end
end
