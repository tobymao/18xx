# frozen_string_literal: true

require_relative '../base'

module Engine
  module Step
    module G1867
      class MajorTrainless < Base
        ACTIONS = %w[pass choose].freeze

        def actions(entity)
          return [] unless trainless_major.include?(entity)

          ACTIONS
        end

        def active_entities
          [trainless_major&.first].compact
        end

        def active?
          trainless_major&.any?
        end

        def description
          'Choose if Major is nationalized'
        end

        def choice_name
          'Nationalize Major?'
        end

        def choices
          { nationalize: 'Nationalize' }
        end

        def process_pass(action)
          @game.trainless_major.delete(action.entity)
          @game.log << "#{action.entity.name} declines to nationalize"
        end

        def process_choose(action)
          @game.trainless_major.delete(action.entity)
          @game.nationalize!(action.entity)
        end

        def trainless_major
          @game.trainless_major
        end
      end
    end
  end
end
