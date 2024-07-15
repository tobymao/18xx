# frozen_string_literal: true

require_relative '../../../step/base'

# Draft certificates to be added to player hands, draft is open information
# Draft order is reverse order for first cycle only, then normal: 4, 3, 2, 1, 1, 2, 3, 4, 1, 2, 3, 4 ...
module Engine
  module Game
    module G18India
      module Step
        class Draft < Engine::Step::Base
          attr_reader :companies, :choices, :grouped_companies

          ACTIONS = %w[bid].freeze

          def setup
            @companies = @game.draft_deck.sort_by { |item| [item.type, -item.value, item.name] }
            @counter = 0
            @reverse_order = true
            @round.entities = @game.players.reverse # Reverse player order for first cycle
          end

          def available
            @companies
          end

          def may_purchase?(_company)
            false
          end

          def may_choose?(_company)
            true
          end

          def auctioning; end

          def bids
            {}
          end

          def visible?
            true
          end

          def players_visible?
            true
          end

          def tiered_auction_companies
            @companies.group_by(&:type).values
          end

          def name
            'Draft'
          end

          def description
            'Draft Certificates'
          end

          def finished?
            @companies.empty?
          end

          def actions(entity)
            return [] if finished?

            entity == current_entity ? ACTIONS : []
          end

          def process_bid(action)
            company = action.company
            player = action.entity

            player.hand << company
            player.hand.sort_by! { |item| [item.name, -item.value] }

            player.draft_history << (company.name + (company.type == :president ? '(Dir)' : ''))

            @companies.delete(company)

            @log << "#{player.name} drafts #{company.type} cert of #{company.name}"

            continue_reverse if @reverse_order
            @round.next_entity_index!
            action_finalized
          end

          def continue_reverse
            @counter += 1
            return unless filp_turn_order?

            @reverse_order = false
            @round.entities = @game.players
          end

          def filp_turn_order?
            (@counter == @round.entities.size) && @reverse_order
          end

          def process_pass(_action); end

          def action_finalized
            return unless finished?

            # setup for after draft round
            @game.draft_completed
          end

          def min_bid(_company); end

          def committed_cash(_player, _show_hidden = false)
            0
          end
        end
      end
    end
  end
end
