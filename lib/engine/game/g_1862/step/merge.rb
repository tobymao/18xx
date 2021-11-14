# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1862
      module Step
        class Merge < Engine::Step::Base
          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity
            return [] if entity.receivership? || @game.skip_round[entity] || @game.lner

            return ['choose'] if @merging

            %w[merge pass]
          end

          def log_skip(entity)
            super unless @game.skip_round[entity]
          end

          def auto_actions(entity)
            return super if @merging

            return [Engine::Action::Pass.new(entity)] if mergeable_candidates(entity).empty?

            super
          end

          def merge_name(_entity = nil)
            'Merge'
          end

          def merger_auto_pass_entity
            current_entity
          end

          def can_merge?(entity)
            mergeable_candidates(entity).any?
          end

          def description
            return 'Choose Survivor' if @merging

            'Merge'
          end

          def process_merge(action)
            @merging = [action.entity, action.corporation]
            @log << "#{@merging.first.name} and #{@merging.last.name} will merge"
          end

          def process_choose(action)
            choose_action(action, :merge)
          end

          def choose_action(action, merge_type)
            survivor, nonsurvivor = action.choice.to_s == 'first' ? @merging : @merging.reverse
            @log << "#{nonsurvivor.name} (non-survivor) will merge into #{survivor.name} (survivor)"
            @game.start_merge(action.entity, survivor, nonsurvivor, merge_type)
            @merging = nil
          end

          def mergeable_type(corporation)
            "Corporations that can merge with #{corporation.name}"
          end

          def setup
            @mergeable_ = {}
          end

          def mergeable_candidates(corporation)
            @mergeable_[corporation] ||=
              begin
                # Mergeable candidates must be connected by track
                parts = @game.graph.connected_nodes(corporation).keys
                  .reject { |n| @game.class::LONDON_TOKEN_HEXES.include?(n.hex.id) }
                mergeable = parts.select(&:city?).flat_map { |c| c.tokens.compact.map(&:corporation) }
                mergeable.uniq.reject { |c| c == corporation || c.receivership? }
              end
          end

          def mergeable(corporation)
            mergeable_candidates(corporation)
          end

          def choice_name
            'Select Corporation to Survive'
          end

          def choices
            {
              first: "#{@merging.first.full_name} (#{@merging.first.name})",
              last: "#{@merging.last.full_name} (#{@merging.last.name})",
            }
          end

          def show_other_players
            false
          end

          def show_other
            @merging ? @merging.last : nil
          end
        end
      end
    end
  end
end
