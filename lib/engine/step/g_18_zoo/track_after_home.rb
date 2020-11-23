# frozen_string_literal: true

require_relative '../track'
require_relative '../../tile'
require_relative '../../action/lay_tile'

module Engine
  module Step
    module G18ZOO
      class TrackAfterHome < Engine::Step::Track
        ACTIONS = %w[lay_tile pass].freeze

        def actions(entity)
          return [] if @game.just_ipoed.nil?
          return [] unless entity == current_entity
          return [] unless entity.player? && can_lay_tile?(@game.just_ipoed)

          ACTIONS
        end

        def available_hex(_entity, hex)
          @game.graph.connected_hexes(@game.just_ipoed)[hex]
        end

        def process_lay_tile(action)
          action_for_corporation = Engine::Action::LayTile.new(@game.just_ipoed, tile: action.tile, hex: action.hex, rotation: action.rotation)

          super(action_for_corporation)
        end

        def log_skip(entity)
          super unless @game.just_ipoed.nil?
        end
      end
    end
  end
end
