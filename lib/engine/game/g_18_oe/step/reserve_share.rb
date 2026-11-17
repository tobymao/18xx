# frozen_string_literal: true

require_relative '../../../step/base'

module Engine
  module Game
    module G18OE
      module Step
        class ReserveShare < Engine::Step::Base
          def round_state
            super.merge(pending_share_buy: nil)
          end

          def active?
            !!@round.pending_share_buy
          end

          def blocks?
            active?
          end

          def active_entities
            active? ? [president] : []
          end

          def actions(entity)
            active? && entity == president ? %w[choose pass] : []
          end

          def choice_available?(entity)
            active? && entity == president
          end

          def choices
            { 'reserve' => 'Reserve share' }
          end

          def choice_name
            "Reserve a share of #{regional.name}? #{@round.pending_share_buy.entity.name} is buying one"
          end

          def pass_description
            'Decline'
          end

          def description
            'Reserve Share'
          end

          def hide_corporations?
            true
          end

          def process_choose(action)
            raise GameError, 'Cannot reserve a share' unless action.choice == 'reserve'
            raise GameError, "Cannot reserve #{regional.name}" unless @game.can_reserve_regional?(action.entity, regional)

            buyer = @round.pending_share_buy.entity
            @log << "#{action.entity.name} reserves a share of #{regional.name}, #{buyer.name}'s purchase is cancelled"
            @log << "#{buyer.name} may buy the other 25% share of #{regional.name} or choose a different action"
            @game.reserve_share!(regional)
            @round.pending_share_buy = nil
          end

          def process_pass(action)
            held = @round.pending_share_buy
            @log << "#{action.entity.name} declines to reserve #{regional.name}"
            buy_step.process_buy_shares(held)
            @round.pending_share_buy = nil
          end

          private

          def regional
            @round.pending_share_buy.bundle.corporation
          end

          def president
            regional.owner
          end

          def buy_step
            @round.steps.find { |step| step.is_a?(G18OE::Step::BuySellParShares) }
          end
        end
      end
    end
  end
end
