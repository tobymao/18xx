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

            %w[merge pass]
          end

          def auto_actions(entity)
            return [Engine::Action::Pass.new(entity)] if acquisition_candidates(entity).empty?
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

          def process_merge(action)
            entity = action.entity
            corporation = action.corporation

            raise GameError, 'Must select a company to merge or takeover' unless corporation
            raise GameError, "Unable to merge or takeover #{corporation.name}" unless can_acquire?(entity, corporation)

            @game.acquire_corporation(entity, corporation)
          end

          def mergeable_type(entity)
            "Corporations that #{entity.name} can merge or takeover"
          end

          def mergeable(entity)
            acquisition_candidates(entity)
          end

          def acquisition_candidates(entity)
            @game.corporations.select { |c| can_acquire?(entity, c) }
          end

          def can_acquire?(entity, corporation)
            return false if entity == corporation
            return false if corporation.closed? || !corporation.floated?

            acquisition_cost = @game.acquisition_cost(entity, corporation)
            if (num_loans_over_the_limit = entity.loans.size + corporation.loans.size - @game.maximum_loans(entity)).positive?
              acquisition_cost += num_loans_over_the_limit * @game.loan_face_value
            end
            return false if acquisition_cost > entity.cash

            corporation_tokened_cities = corporation.tokens.select(&:used).map(&:city)
            !(@game.graph.connected_nodes(entity).keys & corporation_tokened_cities).empty?
          end

          def show_other_players
            true
          end
        end
      end
    end
  end
end
