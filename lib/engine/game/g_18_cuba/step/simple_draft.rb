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
            @completed_actions_player = Hash.new(0)
          end

          def actions_per_player
            # currently only supports 2p medium and 3p short variants,  more variants in the future
            # 2p 2 concessions max, 3-6p 1 concession max
            case @game.players.size
            when 2 then 2
            else 1
            end
          end

          def actions(entity)
            return [] if finished?
            return [] unless entity == current_entity
            return [] if @completed_actions_player[entity.player] >= actions_per_player

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
            @game.players.all? do |player|
              @completed_actions_player[player] >= actions_per_player
            end
          end

          def max_bid(_entity, company)
            may_purchase?(company) ? min_bid(company) : 0
          end

          def process_pass(action)
            player = action.entity.player
            @log << "#{action.entity.name} passes and will not buy any concession"
            @completed_actions_player[player] += 1
            @round.next_entity_index!
            action_finalized
          end

          def process_bid(action)
            super
            player = action.entity.player
            @completed_actions_player[player] += 1
          end
        end
      end
    end
  end
end
