# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1841
      module Step
        class Merge < Engine::Step::Base
          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity
            return [] unless @game.mergeable?(entity)
            return [] if target_corporations.empty?
            return [] if @target

            actions = %w[merge]
            actions << 'pass' unless @merging
            actions
          end

          def setup
            @mergeable_ = {}
            @merging = nil
            @target = nil
          end

          def auto_actions(entity)
            return super if @merging

            return [Engine::Action::Pass.new(entity)] if mergeable_candidates(entity).empty?

            super
          end

          def merge_name(_entity = nil)
            return 'Form' if @merging

            'Merge'
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
              @target = action.corporation
              raise GameError, "#{target.name} is not available to merge into" unless @game.merge_target?(@target)

              @game.merger_start(action.entity, @merging, @target)
            else
              other = action.corporation
              raise GameError, "#{other.name} is the wrong corporation type" if other.type != action.entity.type
              raise GameError, "#{other.name} is not available to merge with" unless @game.mergeable?(other)

              @merging = other
            end
          end

          def mergeable_type(corporation)
            return "Corporations that #{corporation.name} and #{@merging.name} can be merged into to form" if @merging

            "Corporations that can merge with #{corporation.name}"
          end

          def mergeable_candidates(corporation)
            @mergeable_[corporation] ||=
              begin
                # Mergeable candidates must be connected by track and not through a regional border
                # They must be the same type (major/minor)
                parts = @game.token_graph_for_entity(corporation).connected_nodes(corporation).keys
                mergeable = parts.select { |n| n.city? && !n.pass? }.flat_map { |c| c.tokens.compact.map(&:corporation) }
                mergeable.uniq.select { |c| c != corporation && c.type == corporation.type && @game.mergeable?(c) }
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
