# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1854
      module Step
        class MergeMinors < Engine::Step::Base
          def actions(entity)
            return [] unless entity == current_entity
            return [] unless entity.minor?
            return [] unless @game.minor_mergers_allowed?

            actions = ['merge']
            actions << 'pass' if @merging.nil? && !@game.minor_mergers_required?
            actions
          end

          def blocking?
            @game.mergeable?(current_entity)
          end

          def active?
            return false if @passed
            return false if @game.open_minors.empty?

            @game.minor_mergers_allowed? || @game.minor_mergers_required?
          end

          def setup
            @merging = nil
            @merge_target = nil
          end

          def merge_name(entity = nil)
            return "Form #{entity&.name}" if @merging

            "Merge with #{entity&.name}"
          end

          # corps available as a merge target
          def target_corporations
            @game.corporations.select { |c| @game.merge_target?(c) }
          end

          def description
            return 'Choose corporation to form' if @merging

            'Merge'
          end

          def process_merge(action)
            if @merging
              @merge_target = action.corporation
              raise GameError, "#{@merge_target.name} is not available to merge into" unless @game.merge_target?(@merge_target)

              @game.merge_minors_into_lokalbahn(action.entity, @merging, @merge_target)
            else
              other = action.minor

              raise GameError, "#{other.name} is the wrong corporation type" if other.type != action.entity.type
              raise GameError, "#{other.name} is not available to merge with" unless @game.mergeable?(other)

              @merging = other

              @log << "#{@game.formatted_minor_name(action.entity)} and #{@game.formatted_minor_name(other)} selected to merge."
            end
          end

          def mergeable_type(corporation)
            return "Corporations that #{corporation.name} and #{@merging.name} can be merged into to form" if @merging

            "Minors that can merge with #{corporation.name}"
          end

          def mergeable_candidates(corporation)
            @game.minors.uniq.select { |c| c != corporation && @game.mergeable?(c) }
          end

          def mergeable(corporation)
            return target_corporations if @merging

            mergeable_candidates(corporation)
          end

          def show_other_players
            false
          end

          def show_other
            @merging
          end
        end
      end
    end
  end
end
