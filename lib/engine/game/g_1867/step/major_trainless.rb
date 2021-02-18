# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1867
      module Step
        class MajorTrainless < Engine::Step::Base
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

          def choice_available?(entity)
            entity == trainless_major&.first && entity.corporation?
          end

          def swap_sell(_player, _corporation, _bundle, _pool_share); end

          def can_sell?(_entity, _bundle)
            false
          end

          def ipo_type(_entity)
            nil
          end
        end
      end
    end
  end
end
