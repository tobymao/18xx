# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18ESP
      module Step
        class Acquire < Engine::Step::Base
          def actions(entity)
            return [] if !entity.corporation? || entity != current_entity

            return ['choose'] if @merging

            %w[merge pass]
          end

          def auto_actions(entity)
            return super if @merging
            return [Engine::Action::Pass.new(entity)] unless can_merge?(entity)

            super
          end

          def merge_name(_entity = nil)
            'Aquire'
          end

          def merger_auto_pass_entity
            current_entity
          end

          def can_merge?(entity)
            entity.type != :minor &&
            !entity.taken_over_minor &&
            !mergeable_candidates(entity).empty?
          end

          def description
            return 'Choose Survivor' if @merging

            'Merge'
          end

          def process_merge(action)
            @merging = [action.entity, action.corporation]
            @log << "#{@merging.first.name} is taking over #{@merging.last.name}"
          end

          def process_choose(action)
            keep_token = (action.choice.to_s == 'map')
            @game.start_merge(action.entity, @merging.last, keep_token)
            @merging = nil
            pass!
          end

          def mergeable_type(corporation)
            "Minors that #{corporation.name} can acquire"
          end

          def setup
            @mergeable_ = {}
          end

          def mergeable_candidates(corporation)
            return [] if @game.north_corp?(corporation)

            @game.corporations.select do |c|
              next unless c.type == :minor
              next corporation.cash >= @game.class::MINOR_TAKEOVER_COST if @game.minors_stop_operating && !c.floated?
              next true if @game.minors_stop_operating && corporation.cash >= c.share_price&.price
              next true if c.floated? && corporation.cash >= c.share_price&.price && c.operated?

              false
            end
          end

          def mergeable(corporation)
            mergeable_candidates(corporation)
          end

          def choice_name
            'Keep minor company token on map or charter?'
          end

          def choices
            options = {
              charter: 'Charter',
            }
            options[:map] = 'Map' if can_swap?
            options
          end

          def can_swap?
            return true if @game.minors_stop_operating && !mz?(@merging.last)

            @merging.last.tokens.first&.used &&
            !mz?(@merging.last) &&
            @merging.first.tokens.none? { |token| token.hex == @merging.last.tokens.first.hex }
          end

          def mz?(entity)
            entity.id == 'MZ' && @game.corporations.any? { |c| c.id == 'MZA' }
          end

          def show_other_players
            @game.minors_stop_operating
          end

          def show_other
            @merging ? @merging.last : nil
          end

          def log_skip(_entity); end
        end
      end
    end
  end
end
