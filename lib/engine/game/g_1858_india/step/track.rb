# frozen_string_literal: true

require_relative '../../g_1858/step/track'

module Engine
  module Game
    module G1858India
      module Step
        class Track < G1858::Step::Track
          # Extend the base method to allow tiles to be upgraded with gauge
          # conversions. Most of the checks for valid gauge conversions is done
          # in G1858India::Game.gauge_conversion?, here we check that either
          # two paths are converted from broad to narrow gauge (or vice versa)
          # on a city or town tile, or one path on a plain track tile.
          def old_paths_maintained?(hex, tile)
            return super unless @game.gauge_conversion?(hex.tile, tile)

            # gauges is a 2D hash to track the gauges of corresponding paths on
            # the old and new tiles.
            gauges = Hash.new { |h, k| h[k] = Hash.new { |h1, k1| h1[k1] = 0 } }
            hex.tile.paths.each do |path|
              new_path = tile.paths.find do |other|
                path.ends.all? { |pe| other.ends.any? { |oe| pe <= oe } }
              end
              return false unless new_path

              gauges[path.track][new_path.track] += 1
            end

            valid_changes = tile.city_towns.empty? ? 1 : 2
            (gauges[:broad][:narrow].zero? && (gauges[:narrow][:broad] == valid_changes)) ||
            (gauges[:narrow][:broad].zero? && (gauges[:broad][:narrow] == valid_changes))
          end
        end
      end
    end
  end
end
