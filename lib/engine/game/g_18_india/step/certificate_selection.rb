# frozen_string_literal: true

require_relative '../../../step/base'
require_relative '../player'
require_relative '../game'

module Engine
  module Game
    module G18India
      module Step
        class CertificateSelection < Engine::Step::Base
          attr_reader :companies, :choices

          ACTIONS = %w[bid].freeze
          # ACTIONS_WITH_PASS = %w[bid pass].freeze

          def setup
            @log << "Setup in CertificateSelection called with opts #{@opts}"
            @companies = @game.companies
            @choices = Hash.new { |h, k| h[k] = [] }
            @cards_to_keep = @game.certs_to_keep
            @draft_deck = @game.draft_deck
          end

          def pass_description
            if selections_completed?
              'Choose Selected Certs'
            elsif number_of_selections > @cards_to_keep
              'Too Many Certs Selected'
            else
              "Choose #{@cards_to_keep - number_of_selections} more Certs"
            end
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

          def selections_completed?
            return true if number_of_selections == @cards_to_keep

            false
          end

          def number_of_selections
            current_entity.hand.count { |s| s.owner == current_entity }
          end

          def visible?
            # test if this makes selections visible to others when selecting cards
            # false
            number_of_selections.positive?
          end

          def players_visible?
            false
          end

          def name
            'Hand Selection Round'
          end

          def description
            "Select #{@cards_to_keep} Certificates for your starting hand"
          end

          def all_players_selected?
            @game.players.each do |p|
              return false unless p.hand.count { |s| s.owner == p } == @cards_to_keep
            end
            true
          end

          def all_players_passed?
            @game.players.all.passed?
          end

          def finished?
            all_players_selected?
          end

          def actions(entity)
            return [] if finished?

            actions = ACTIONS
            if entity == current_entity then @hide = false end # test to see what this statement does
            entity == current_entity ? actions : []
          end

          def process_pass(_action)
            # @log << "Process Pass called in Cert Selection"
            return unless selections_completed?

            @round.next_entity_index!
            action_finalized
          end

          def process_bid(action)
            # @log << "Process Bid called in Cert Selection"
            choose_company(action.entity, action.company)
            if selections_completed?
              log_selection(action.entity)
              @round.next_entity_index!
            end
            action_finalized
          end

          def log_selection(entity)
            return unless entity.player?

            @log << "#{entity.name} slected #{@cards_to_keep} certificates for hand"
          end

          def choose_company(player, company)
            return if player.nil? || company.nil?

            available_companies = available
            raise GameError, "Cannot choose #{company.name}" unless available_companies.include?(company)

            company.owner = if company.owner == player
                              nil
                            else
                              player
                            end
            # @log << "You have selected #{self.number_of_selections} out of #{@cards_to_keep}"
          end

          def action_finalized
            # @log << "Action Finalized called in Cert Selection"
            return unless finished?

            @log << 'Inital hand selection completed.'
            @game.prepare_draft_deck
            @round.reset_entity_index!
          end

          def committed_cash(_player, show_hidden = false)
            return 0 unless show_hidden

            0
          end
        end
      end
    end
  end
end
