# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18NY
      module Step
        class AcquireCorporation < Engine::Step::Base
          def actions(entity)
            return [] if entity != current_entity
            return [] unless entity.corporation?
            return [] unless @round.view_merge_options

            %w[merge pass]
          end

          def auto_actions(entity)
            return if entity != current_entity || !@round.view_merge_options || !@game.acquisition_candidates(entity).empty?

            [Engine::Action::Pass.new(entity)]
          end

          def merge_name(entity = nil)
            return 'Merge/Takeover' unless entity

            "#{merge_type(entity)} (#{@game.format_currency(@game.acquisition_cost(current_entity, entity) * -1)})"
          end

          def merge_type(entity)
            current_entity.owner == entity.owner ? 'Merge' : 'Takeover'
          end

          def merger_auto_pass_entity
            current_entity
          end

          def description
            'Mergers and Takeovers'
          end

          def blocks?
            @round.view_merge_options
          end

          def pass_description
            'Done (Mergers/Takeovers)'
          end

          def process_merge(action)
            entity = action.entity
            corporation = action.corporation

            raise GameError, 'Must select a company to merge or takeover' unless corporation
            raise GameError, "Unable to merge or takeover #{corporation.name}" unless @game.can_acquire?(entity, corporation)

            @game.acquire_corporation(entity, corporation)
          end

          def process_pass(_action)
            @round.view_merge_options = false
          end

          def mergeable_type(entity)
            "Corporations that #{entity.name} can merge or takeover"
          end

          def mergeable(entity)
            @game.acquisition_candidates(entity)
          end

          def show_other_players
            true
          end
        end
      end
    end
  end
end
