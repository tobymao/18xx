# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1841
      module Step
        class Transform < Engine::Step::Base
          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity || @game.done_this_round[entity]
            return [] if @xform_target
            return [] unless @game.transformable?(entity)
            return [] if target_corporations.empty?

            %w[merge pass]
          end

          def setup
            @xform_target = nil
          end

          def merge_name(_entity = nil)
            'Transform'
          end

          # corps available as a transform target
          def target_corporations
            @game.corporations.select { |c| @game.merge_target?(c) }
          end

          def description
            'Transform minor into major'
          end

          def process_merge(action)
            @xform_target = action.corporation
            raise GameError, "#{@xform_target.name} is not available to merge into" unless @game.merge_target?(@xform_target)

            @game.transform_start(action.entity, @xform_target)
          end

          def mergeable_type(corporation)
            "Corporations that #{corporation.name} can be transformed into"
          end

          def mergeable(_corporation)
            target_corporations
          end

          def show_other_players
            false
          end

          def show_other
            true
          end
        end
      end
    end
  end
end
