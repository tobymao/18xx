# frozen_string_literal: true

require_relative '../../g_1822/step/track'
require_relative 'tracker'

module Engine
  module Game
    module G1822CA
      module Step
        class Track < G1822::Step::Track
          include G1822CA::Tracker

          def process_pass(action)
            super

            return unless (tile_grant = action.entity.companies.find { |c| c.id == @game.class::COMPANY_LSR })
            return if tile_grant.closed?
            return unless (ability = tile_grant.all_abilities[0])
            return unless ability.used?

            @log << "#{tile_grant.name} closes"
            tile_grant.close!
          end
        end
      end
    end
  end
end
