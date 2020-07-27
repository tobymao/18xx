# frozen_string_literal: true

require_relative '../special_track'

module Engine
  module Step
    module G18Chesapeake
      class SpecialTrack < SpecialTrack

        ACTIONS = %w[lay_tile].freeze

        def actions(entity)
          return [] unless ability(entity)

          ACTIONS
        end

        def description
          "Lay Track for #{@company.name}"
        end

        def active_entities
          @company ? [@company] : super
        end

        def blocks?
          @company && ability(@company)
        end

        def process_lay_tile(action)
          company = action.entity
          hex_ids = ability(company).hexes

          super

          if company == @company
            paths = hex_ids.flat_map do |hex_id|
              @game.hex_by_id(hex_id).tile.paths
            end.uniq

            raise GameError, 'Paths must be connected' if paths.size != paths[0].select(paths).size
          end

          @company = company
        end

        def setup
          @company = nil
        end
      end
    end
  end
end
