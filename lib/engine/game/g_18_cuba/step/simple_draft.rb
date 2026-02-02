# frozen_string_literal: true

require_relative '../../../step/simple_draft'

module Engine
  module Game
    module G18Cuba
      module Step
        class SimpleDraft < Engine::Step::SimpleDraft
          def setup
            super
            @companies = @game.concessions.sort
            @completed_players = {}
          end

          def actions(entity)
            return [] if finished?
            return [] unless entity == current_entity

            %w[bid pass]
          end

          def may_purchase?(company)
            @game.concessions.include?(company)
          end

          def can_pass?(_entity)
            true
          end

          def description
            'Draft Concessions'
          end

          def finished?
            @game.players.all? { |p| @completed_players[p] }
          end

          def max_bid(_entity, company)
            may_purchase?(company) ? min_bid(company) : 0
          end

          def process_pass(action)
            player = action.entity.player
            @log << "#{action.entity.name} passes and will not buy any concession"
            @completed_players[player] = true
            @round.next_entity_index!
            action_finalized
          end

          def process_bid(action)
            super
            player = action.entity.player
            @completed_players[player] = true
          end
        end
      end
    end
  end
end
