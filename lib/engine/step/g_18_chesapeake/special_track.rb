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

        def active_entities
          @company ? [@company] : super
        end

        def blocks?
          @company && ability(@company)
        end
      end
    end
  end
end
