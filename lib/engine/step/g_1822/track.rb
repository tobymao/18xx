# frozen_string_literal: true

require_relative '../track'
require_relative 'tracker'

module Engine
  module Step
    module G1822
      class Track < Engine::Step::Track
        include Tracker

        def available_hex(entity, hex)
          connected = super
          return nil unless connected

          # London yellow tile counts as an upgrade
          if hex.tile.color == :white && @round.num_laid_track.positive? && hex.name == @game.class::LONDON_HEX
            return nil
          end

          connected
        end

        def check_track_restrictions!(entity, old_tile, new_tile)
          return if @game.loading || !entity.operator?
          return if new_tile.hex.name == @game.class::ENGLISH_CHANNEL_HEX

          super
        end

        def process_lay_tile(action)
          super
          @game.after_lay_tile(action.hex, action.tile)
        end
      end
    end
  end
end
