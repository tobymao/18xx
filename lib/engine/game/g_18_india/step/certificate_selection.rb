# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../player'
require_relative '../game'

# Each player will select multiple certs to keep from intial hand
# Selections and hands should be kept hidden from other players
module Engine
  module Game
    module G18India
      module Step
        class CertificateSelection < Engine::Step::Base
          attr_reader :companies, :choices

          ACTIONS = %w[bid].freeze
          ACTIONS_WITH_PASS = %w[bid pass].freeze

          def setup
            @companies = @game.companies
            @choices = Hash.new { |h, k| h[k] = [] }
            @cards_to_keep = @game.certs_to_keep
            @confirmed_selections = 0
          end

          def pass_description
            'Complete Selection'
          end

          def available
            current_entity.hand.sort.reverse
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
            false
          end

          def players_visible?
            false
          end

          def name
            'Hand Selection'
          end

          def description
            "Select #{@cards_to_keep} Certificates for your starting hand"
          end

          def finished?
            @confirmed_selections == @game.players.size
          end

          def selections_completed?
            number_of_selections == @cards_to_keep
          end

          def number_of_selections
            current_entity.hand.count { |s| s.owner == current_entity }
          end

          def actions(entity)
            return [] if finished?
            return [] unless entity == current_entity

            if selections_completed? 
              ACTIONS_WITH_PASS
            else
              ACTIONS
            end
          end

          def process_pass(action)
            @log << "#{action.entity.name} selected #{@cards_to_keep} certificates for hand"
            @confirmed_selections += 1
            @round.next_entity_index!
            action_finalized
          end

          def process_bid(action)
            choose_company(action.entity, action.company)
            @game.next_turn! 
            action_finalized
          end

          def choose_company(player, company)
            company.owner = player
          end

          def action_finalized
            return unless finished?
            @log << "Inital hand selections completed"
            @game.prepare_draft_deck
          end

          def committed_cash(_player, _show_hidden)
            return 0
          end

        end
      end
    end
  end
end
