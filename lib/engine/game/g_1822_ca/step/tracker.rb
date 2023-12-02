# frozen_string_literal: true

module Engine
  module Game
    module G1822CA
      module Tracker
        def old_paths_maintained?(hex, tile)
          if hex.tile.name == 'AG13' && hex.tile.color == :white
            %w[5 6 57].include?(tile.name)
          else
            super
          end
        end

        def abilities(entity, **kwargs, &block)
          abilities = Array(super)

          if @round.num_laid_track.positive?
            abilities.reject! do |ability|
              ability.type == :tile_lay && ability.consume_tile_lay
            end
          end

          abilities.size > 1 ? abilities : abilities[0]
        end
      end
    end
  end
end
