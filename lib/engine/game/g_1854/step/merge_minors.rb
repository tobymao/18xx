# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1854
      module Step
        class MergeMinors < Engine::Step::Base
          def actions(entity)
            return [] if !entity.minor? || entity != current_entity #  || @game.done_this_round[entity]
            return [] unless @game.mergeable?(entity)
            return [] if target_corporations.empty?
            return [] if @merge_target

            %w[merge].freeze
          end

          def blocking?
            @merge_target.nil?
          end

          def setup
            @mergeable_ = {}
            @merging = nil
            @merge_target = nil
          end

          def auto_actions(entity)
            return super if @merging

            return [Engine::Action::Pass.new(entity)] if mergeable_candidates(entity).empty?

            super
          end

          def merge_name(_entity = nil)
            return "Form #{_entity&.name}" if @merging

            "Merge with #{_entity&.name}"
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
            @mergeable_[corporation] ||=
              begin
                # # Mergeable candidates must be connected by track and not through a regional border
                # # They must be the same type (major/minor)
                # parts = @game.token_graph_for_entity(corporation).connected_nodes(corporation).keys
                # mergeable = parts.select { |n| n.city? && !n.pass? }.flat_map { |c| c.tokens.compact.map(&:corporation) }
                @game.minors.uniq.select { |c| c != corporation && @game.mergeable?(c) }
              end
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
