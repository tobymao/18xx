# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative '../../../step/track_lay_when_company_sold'

module Engine
  module Game
    module GFrost1831
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include Engine::Step::TrackLayWhenCompanySold

          def blocking_for_sold_company?
            return false unless super
            return true if sold_tile_available?

            @company = nil
            false
          end

          private

          def sold_tile_available?
            ability = @game.abilities(@company, :tile_lay, time: 'sold')
            ability.hexes.any? do |hex_id|
              hex = @game.hex_by_id(hex_id)
              potential_tiles(@company, hex).any? do |tile|
                rotation = tile.rotation
                legal = !legal_tile_rotations(@company, hex, tile).empty?
                tile.rotate!(rotation)
                legal
              end
            end
          end
        end
      end
    end
  end
end
