# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18TN
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

        private

        def remaining_tile_lay?(entity)
          can_lay_tile?(entity) ||
          @game.companies.find { |c| c.owner == entity && c.abilities(:tile_lay)&.count&.positive? }
        end
      end
    end
  end
end
