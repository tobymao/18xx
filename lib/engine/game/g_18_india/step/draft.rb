# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18India
      module Step
        class Draft < Engine::Step::Base
          attr_reader :companies, :choices  #, :grouped_companies (check if grouping useful)

          ACTIONS = %w[bid].freeze

          def setup
            @companies = @game.draft_deck.sort_by { |item| [item.name, -item.value] }
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
            @companies.group_by(&:revenue).values
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

            company.owner = player
            player.hand << company

            @companies.delete(company)

            @log << "#{player.name} drafts #{company.name}"

            @round.next_entity_index!
            action_finalized
          end

          def process_pass(action); end

          def action_finalized
            return unless finished?
            #  check to maintain player order
            @round.reset_entity_index!
          end

          def committed_cash(_player, _show_hidden = false)
            0
          end

          def min_bid(company); end

          def skip!
            current_entity.pass!
            @round.next_entity_index!
            action_finalized
          end

        end
      end
    end
  end
end
