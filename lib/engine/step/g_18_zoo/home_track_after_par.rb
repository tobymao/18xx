# frozen_string_literal: true

require_relative '../track'
require_relative '../../tile'
require_relative '../../action/lay_tile'

module Engine
  module Step
    module G18ZOO
      class HomeTrackAfterPar < Track
        ACTIONS = %w[lay_tile pass].freeze
        ACTIONS_YELLOW_TRACK = %w[lay_tile].freeze

        def actions(entity)
          return [] if @game.floated_corporation.nil?
          return [] unless entity == current_entity
          return [] unless entity.player? && can_lay_tile?(@game.floated_corporation)

          hex = @game.hex_by_id(@game.floated_corporation.coordinates)
          return ACTIONS_YELLOW_TRACK if hex.tile.color == 'white'

          ACTIONS
        end

        def hex_neighbors(_entity, hex)
          return false unless @game.floated_corporation.coordinates == hex.coordinates

          @game.graph.connected_hexes(@game.floated_corporation)[hex]
        end

        def process_lay_tile(action)
          super(Engine::Action::LayTile.new(@game.floated_corporation,
                                            tile: action.tile,
                                            hex: action.hex,
                                            rotation: action.rotation))
        end

        def log_skip(entity)
          super unless @game.floated_corporation.nil?
        end
      end
    end
  end
end
