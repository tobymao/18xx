# frozen_string_literal: true

require_relative '../track'

module Engine
  module Step
    module G18MS
      class Track < Track
        ACTION_HEX_OF_INTEREST = 'B10'
        BONUS_HEX = 'B12'

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

        def lay_tile(action, extra_cost: 0, entity: nil)
          entity ||= action.entity
          super

          return if @game.chattanooga_reached ||
            action.tile.hex.name != ACTION_HEX_OF_INTEREST ||
            !@game.graph.reachable_hexes(entity).find { |h, _| h.name == 'B12' }

          @game.chattanooga_reached = true
          @game.remove_icons(BONUS_HEX)
          bonus = 50
          entity.cash += bonus
          hex_name = @game.get_location_name(BONUS_HEX)
          @log << "#{entity.name} connects to #{hex_name} and receives #{@game.format_currency(bonus)}"
        end

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
