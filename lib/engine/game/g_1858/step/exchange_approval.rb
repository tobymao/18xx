# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'private_exchange'

module Engine
  module Game
    module G1858
      module Step
        class ExchangeApproval < Engine::Step::Base
          include PrivateExchange

          def round_state
            super.merge(
              {
                minor: nil,
                approvals: {},
                pending_approval: nil,
              }
            )
          end

          def actions(entity)
            return [] unless entity == corporation

            ['choose']
          end

          def active?
            pending_approval
          end

          def active_entities
            in_pcr? ? [corporation] : [approver]
          end

          def current_entity
            corporation
          end

          def corporation
            pending_approval
          end

          def minor
            @round.minor
          end

          def approver
            corporation.owner
          end

          def requester
            minor.owner
          end

          def in_pcr?
            @game.private_closure_round == :in_progress
          end

          def pending_approval
            @round.pending_approval
          end

          def description
            'Approve or deny exchange request'
          end

          def choice_name
            "Allow #{requester.name} to exchange #{minor.id} for a treasury share"
          end

          def choice_available?(entity)
            entity == corporation
          end

          def ipo_type(_entity)
            nil
          end

          def choices
            {
              'approve' => 'Allow exchange',
              'deny' => 'Do not allow exchange',
            }
          end

          def process_choose(action)
            approved = (action.choice == 'approve')
            log_response(corporation, minor, approved)
            if approved
              share = corporation.shares.first
              exchange_for_share(share, corporation, minor, minor.owner, true)
              if in_pcr?
                @game.close_private(minor)
              else
                # Need to add an action to the action log, but this can't be a
                # buy shares action as that would end the current player's turn.
                @round.current_actions << Engine::Action::Base.new(minor)
              end
            elsif in_pcr?
              @round.approvals[corporation] = :denied
              if corporation.num_market_shares.positive? && in_pcr?
                @game.log << "#{minor.name} may now be exchanged for a " \
                             "#{corporation.id} market share."
              end
            end
            @round.pending_approval = nil
          end
        end
      end
    end
  end
end
