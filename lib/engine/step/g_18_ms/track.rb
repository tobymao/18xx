# frozen_string_literal: true

require_relative '../track'
require_relative 'lay_tile_with_chattanooga_check'

module Engine
  module Step
    module G18MS
      class Track < Track
        ACTIONS = %w[lay_tile pass].freeze

        def actions(entity)
          return [] if entity.company? || !remaining_tile_lay?(entity)

          entity == current_entity ? ACTIONS : []
        end

        def process_lay_tile(action)
          @game.game_error('Cannot do normal tile lay') unless can_lay_tile?(action.entity)
          lay_tile_action(action)
          pass! unless remaining_tile_lay?(action.entity)
        end

        include LayTileWithChattanoogaCheck

        private

        def remaining_tile_lay?(entity)
          return true if can_lay_tile?(entity)

          use_left = 0

          [@game.p1_company, @game.p2_company]
            .select { |p| p.owner == entity }
            .each do |p|
              ability = p.abilities(:tile_lay)
              use_left += ability.count if ability
            end

          use_left.positive?
        end
      end
    end
  end
end
