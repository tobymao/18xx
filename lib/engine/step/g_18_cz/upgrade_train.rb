# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G18CZ
      class UpgradeTrain < Base
        ACTIONS = %w[upgrade_train discard_train].freeze

        def actions(entity)
          return [] unless entity == buying_entity

          ACTIONS
        end

        def active_entities
          [buying_entity]
        end

        def round_state
          {
            bought_trains: [],
          }
        end

        def active?
          buying_entity
        end

        def current_entity
          buying_entity
        end

        def buying_entity
          bought_trains[:entity]
        end

        def trains
          bought_trains[:trains]
        end

        def bought_trains
          @round.bought_trains&.first || {}
        end

        def description
          "Upgrade or discard bought trains #{buying_entity.name}"
        end

        def process_lay_tile(action); end
      end
    end
  end
end
