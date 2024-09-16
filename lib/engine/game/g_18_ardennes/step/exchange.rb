# frozen_string_literal: true

require_relative '../../../step/exchange'
require_relative 'minor_exchange'

module Engine
  module Game
    module G18Ardennes
      module Step
        class Exchange < Engine::Step::Exchange
          include MinorExchange

          def round_state
            super.merge(
              {
                major: nil,
                minor: nil,
                optional_trains: [],
                corporations_removing_tokens: nil,
                optional_forts: [],
              }
            )
          end

          def bought?
            @round.current_actions.any? do |action|
              Engine::Step::BuySellParShares::PURCHASE_ACTIONS.include?(action.class)
            end
          end

          def can_exchange?(entity, _bundle = nil)
            return false unless entity.corporation?
            return false unless entity.type == :minor

            @round.stock? ? !bought? : !@round.converted.nil?
          end

          def process_buy_shares(action)
            unless can_exchange?(action.entity, action.bundle)
              raise GameError, "Cannot exchange #{action.entity.id} for " \
                               "#{action.bundle.corporation.id}"
            end

            bundle = action.bundle
            share = bundle.shares.first
            @round.minor = action.entity
            @round.major = share.corporation
            if approval_needed?(@round.minor, share)
              log_request(@round.minor, @round.major)
              @round.pending_approval = @round.major
              @round.bundle = bundle
            else
              transfer = treasury_share?(share) ? :choose : :none
              exchange_minor(@round.minor, bundle, transfer)
              @round.current_actions << action if @round.stock?
            end
          end

          private

          # Does this bundle contain a treasury share, or one from the bank pool?
          def treasury_share?(share)
            share.corporation.shares.include?(share)
          end

          def approval_needed?(minor, share)
            corporation = share.corporation

            !corporation.operating_history.empty? &&
              minor.owner != corporation.owner &&
              treasury_share?(share) &&
              !corporation.receivership?
          end

          def log_request(minor, major)
            msg = "#{minor.owner.name} requested #{major.owner.name}’s " \
                  "permission to exchange minor #{minor.name} for a " \
                  "#{major.id} treasury share."
            @round.process_action(Engine::Action::Log.new(minor.owner, message: msg))
          end
        end
      end
    end
  end
end
