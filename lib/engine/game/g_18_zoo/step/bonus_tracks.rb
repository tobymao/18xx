# frozen_string_literal: true

module Engine
  module Game
    module G18ZOO
      module Step
        class BonusTracks < Engine::Step::Track
          ACTIONS = %w[lay_tile pass].freeze

          def actions(entity)
            return [] if entity != current_entity || !can_lay_tile?(current_entity)

            ACTIONS
          end

          def setup
            super

            @round.bonus_tracks = 0
          end

          def round_state
            super.merge(
              {
                pending_tokens: [],
                bonus_tracks: 0,
              }
            )
          end

          def description
            "Lay bonus tracks for #{current_entity.name}"
          end

          def active?
            current_entity && @round.bonus_tracks.positive?
          end

          def current_entity
            @round.floated_corporation
          end

          def process_lay_tile(action)
            super

            @round.bonus_tracks = 0 if @round.num_laid_track == @round.bonus_tracks
          end

          def process_pass(action)
            super

            @round.bonus_tracks = 0
          end
        end
      end
    end
  end
end
