# frozen_string_literal: true

require_relative '../../../step/track'

module Engine
  module Game
    module G18Carolinas
      module Step
        class Track < Engine::Step::Track
          LAY_ACTIONS = %w[lay_tile pass].freeze
          ALL_ACTIONS = %w[lay_tile choose pass].freeze

          def actions(entity)
            return [] unless entity == current_entity
            return [] if entity.corporation? && entity.receivership?
            return [] if entity.company? || !can_lay_tile?(entity) && !conversion_available?

            conversion_available? ? ALL_ACTIONS : LAY_ACTIONS
          end

          def conversion_available?
            @game.phase.available?('5') && @round.num_laid_track.zero?
          end

          def round_state
            super.merge(
              {
                convert_mode: nil,
              }
            )
          end

          def setup
            super
            @round.convert_mode = nil
          end

          def update_tile_lists(tile, old_tile)
            @game.update_tile_lists!(tile, old_tile)
          end

          def choice_name
            'Switch to'
          end

          def choices
            {
              conversion: 'Track Conversion Mode',
            }
          end

          def process_choose(_action)
            @round.convert_mode = true
            @log << 'Switching to Track Conversion Mode'
            pass!
          end
        end
      end
    end
  end
end
