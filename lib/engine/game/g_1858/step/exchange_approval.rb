# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'private_exchange'

module Engine
  module Game
    module G1858
      module Step
        class ExchangeApproval < Engine::Step::Base
          include PrivateExchange

          def actions(entity)
            return [] unless entity == corporation

            ['choose']
          end

          def active?
            pending_approval
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

          def pending_approval
            @round.pending_approval
          end

          def description
            'xyzzy'
          end

          def choice_name
            "Allow #{requester.name} to exchange #{minor.id} for a treasury share"
          end

          def choices
            {
              'approve' => 'Allow exchange',
              'deny' => 'Do not allow exchange',
            }
          end

          def process_choose(action)
            approved = (action.choice == 'approve')
            verb = approved ? 'approved' : 'denied'
            msg = "• #{verb} #{requester.name}’s request to exchange " \
                  "#{minor.name} for a #{corporation.id} treasury share."
            @round.process_action(Engine::Action::Log.new(approver, message: msg))

            if approved
              share = corporation.shares.first
              exchange_for_share(share, corporation, minor, minor.owner, true)
              @game.close_private(minor)
            else
              @round.approvals[corporation] = :denied
              if corporation.num_market_shares.positive?
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
