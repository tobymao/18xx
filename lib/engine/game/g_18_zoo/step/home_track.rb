# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class HomeTrack < Engine::Step::Track
          ACTIONS = %w[lay_tile].freeze
          ACTIONS_WITH_PASS = %w[lay_tile pass].freeze

          def actions(_entity)
            return [] unless can_lay_tile?(current_entity)

            hex_color = @game.hex_by_id(current_entity.coordinates).tile.color
            return ACTIONS if hex_color == :white && available_track?

            ACTIONS_WITH_PASS
          end

          def round_state
            super.merge(
              {
                pending_tokens: [],
                floated_corporation: nil,
                available_tracks: [],
              }
            )
          end

          def description
            "Lay home track for #{current_entity.name}"
          end

          def pass_description
            return 'Skip (no tiles available)' unless available_track?

            super
          end

          def active?
            current_entity && !@round.available_tracks.empty?
          end

          def help
            "#{current_entity.name} should place the home track"
          end

          def current_entity
            @round.floated_corporation
          end

          def hex_neighbors(_entity, hex)
            return false unless current_entity.coordinates == hex.coordinates

            @game.graph.connected_hexes(current_entity)[hex]
          end

          def process_lay_tile(action)
            super(Engine::Action::LayTile.new(current_entity,
                                              tile: action.tile,
                                              hex: action.hex,
                                              rotation: action.rotation))

            @round.available_tracks = []
            @round.num_laid_track = 0
          end

          def process_pass(action)
            super

            @round.available_tracks = []
            @round.num_laid_track = 0
          end

          private

          def available_track?
            @game.tiles.any? { |t| @round.available_tracks.include?(t.name) }
          end
        end
      end
    end
  end
end
