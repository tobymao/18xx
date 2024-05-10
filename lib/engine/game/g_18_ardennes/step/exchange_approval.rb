# frozen_string_literal: true

require_relative '../../../step/base'
require_relative 'minor_exchange'

module Engine
  module Game
    module G18Ardennes
      module Step
        class ExchangeApproval < Engine::Step::Base
          include MinorExchange

          def round_state
            super.merge(
              {
                minor: nil,
                bundle: nil,
                pending_approval: nil,
                refusals: Hash.new { |h, k| h[k] = [] },
              }
            )
          end

          def actions(entity)
            return [] unless entity == major

            ['choose']
          end

          def active?
            pending_approval
          end

          def active_entities
            [approver]
          end

          def current_entity
            major
          end

          def description
            'Approve or deny exchange request'
          end

          def choice_name
            "Allow #{requester.name} to exchange minor #{minor.name} " \
              'for a treasury share'
          end

          def choice_available?(entity)
            entity == major
          end

          def choices
            {
              'approve' => 'Allow exchange',
              'deny' => 'Do not allow exchange',
            }
          end

          def ipo_type(_entity)
            nil
          end

          def process_choose(action)
            approved = (action.choice == 'approve')
            log_response(minor, major, approved)
            if approved
              exchange_minor(@round.minor, bundle, :choose)
            else
              @round.refusals[major] << minor
              if major.num_market_shares.positive?
                @game.log << "Minor #{minor.name} may now be exchanged for a " \
                             "#{major.id} market share."
              end
            end
            @round.pending_approval = nil
          end

          private

          def major
            pending_approval
          end

          def minor
            @round.minor
          end

          def bundle
            @round.bundle
          end

          def approver
            major.owner
          end

          def requester
            minor.owner
          end

          def pending_approval
            @round.pending_approval
          end

          def log_response(minor, major, approved)
            msg = "#{approver.name} #{approved ? 'approved' : 'denied'} " \
                  "#{requester.name}’s request to exchange minor " \
                  "#{minor.name} for a #{major.id} treasury share."
            @round.process_action(Engine::Action::Log.new(approver, message: msg))
          end
        end
      end
    end
  end
end
