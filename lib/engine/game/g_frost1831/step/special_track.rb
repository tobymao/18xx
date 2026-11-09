# frozen_string_literal: true

require_relative '../../../step/special_track'
require_relative '../../../step/track_lay_when_company_sold'

module Engine
  module Game
    module GFrost1831
      module Step
        class SpecialTrack < Engine::Step::SpecialTrack
          include Engine::Step::TrackLayWhenCompanySold

          PASS_ACTION = %w[pass].freeze

          def actions(entity)
            return super unless blocking_for_sold_company?
            return super if sold_tile_available?

            PASS_ACTION
          end

          def auto_actions(entity)
            return super unless blocking_for_sold_company?
            return super if sold_tile_available?

            [Engine::Action::Pass.new(@company)]
          end

          private

          def sold_tile_available?
            ability = @game.abilities(@company, :tile_lay, time: 'sold')
            ability.hexes.any? do |hex_id|
              !upgradeable_tiles(@company, @game.hex_by_id(hex_id)).empty?
            end
          end
        end
      end
    end
  end
end
