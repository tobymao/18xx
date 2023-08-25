# frozen_string_literal: true

require_relative '../../g_1822/step/tracker'

module Engine
  module Game
    module G1822CA
      module Tracker
        include G1822::Tracker

        def old_paths_maintained?(hex, tile)
          if hex.tile.name == 'AG13' && hex.tile.color == :white
            %w[5 6 57].include?(tile.name)
          else
            super
          end
        end

        def abilities(entity, **kwargs, &block)
          ability = super

          # P19-P20 Mountain Pass privates
          if ability && @game.class::MOUNTAIN_PASS_COMPANIES.include?(entity.id)
            # consume full turn's tile lay
            return if @round.num_laid_track.positive?

            # useless if someone's already paid for the mountain pass
            hex = @game.hex_by_id(@game.class::MOUNTAIN_PASS_COMPANIES_TO_HEXES[entity.id])
            return unless hex.tile.color == :white
          end

          ability
        end
      end
    end
  end
end
