# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G1893
      module Step
        class Merger < Engine::Step::Base
          ACTIONS = %w[special_buy].freeze

          def round_state
            {
              choice_done: false,
            }
          end

          def actions(entity)
            return [] if entity.company?
            return [] unless choice_available?
            return [] if @game.round.merger_candidates_for(@game.round.current_entity).empty?

            ACTIONS
          end

          def description
            "Merge of #{@game.round.merge_target.name}"
          end

          def entities
            @game.round.voters
          end

          def buyable_items(_entity)
            return [] unless choice_available?

            [Item.new(description: 'yes', cost: 0),
             Item.new(description: 'no', cost: 0)]
          end

          def item_str(item)
            case item.description
            when 'yes'
              "Yes (#{@game.round.yes}% so far)"
            when 'no'
              "No (#{@game.round.no}% so far)"
            end
          end

          def help
            names = @game.round.names(@game.round.merger_candidates_for(@game.round.current_entity))
            "Vote Yes or No to merge #{names} into #{@game.round.merge_target.name}. " \
              '50% Yes votes is required to execute merge. If No votes exceed 50% merge is postponed. ' \
              'Note! Even if declined, there is an automatic merge at the start of the Merge Round following '\
              'the next phase change.'
          end

          def active?
            choice_available?
          end

          def blocking?
            choice_available?
          end

          def purchasable_companies(_entity = nil)
            []
          end

          def process_special_buy(action)
            @round.choice_done = true
            @round.handle_vote(action.item.description)
            @round.next_entity!
          end

          def choice_available?
            !@game.round.offering.empty? || !@game.round.done
          end

          def can_sell?
            false
          end

          def ipo_type(_entity) end

          def swap_sell(_player, _corporation, _bundle, _pool_share); end
        end
      end
    end
  end
end
