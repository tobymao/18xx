# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'tracker'

module Engine
  module Game
    module G1822
      module Step
        class Track < Engine::Step::Base
          include Engine::Game::G1822::Tracker

          ACTIONS = %w[lay_tile pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.company? || !can_lay_tile?(entity)

            ACTIONS
          end

          def description
            tile_lay = get_tile_lay(current_entity)
            return 'Lay Track' unless tile_lay

            if tile_lay[:lay] && tile_lay[:upgrade]
              'Lay/Upgrade Track'
            elsif tile_lay[:lay]
              'Lay Track'
            else
              'Upgrade Track'
            end
          end

          def pass_description
            @acted ? 'Done (Track)' : 'Skip (Track)'
          end

          def process_lay_tile(action)
            lay_tile_action(action)
            pass! unless can_lay_tile?(action.entity)

            @game.after_lay_tile(action.hex, action.tile)
          end

          def process_pass(action)
            super

            @game.after_track_pass(action.entity)
          end

          def available_hex(entity, hex)
            connected = hex_neighbors(entity, hex)
            return nil unless connected

            tile_lay = get_tile_lay(entity)
            return nil unless tile_lay

            color = hex.tile.color
            return nil if color == :white && !tile_lay[:lay]
            return nil if color != :white && !tile_lay[:upgrade]
            return nil if color != :white && tile_lay[:cannot_reuse_same_hex] && @round.laid_hexes.include?(hex)

            # London yellow tile counts as an upgrade
            if hex.tile.color == :white && @round.num_laid_track.positive? && hex.name == @game.class::LONDON_HEX
              return nil
            end

            connected
          end
        end
      end
    end
  end
end
