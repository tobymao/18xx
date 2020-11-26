# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class IssueShares < Snabberb::Component
      include Actionable

      needs :entity, default: nil
      def render
        @step = @game.round.active_step
        @entity ||= @game.current_entity
        @current_actions = @game.round.actions_for(@entity)
        children = []

        if @current_actions.include?('sell_shares')
          if (step = @game.round.step_for(@entity, 'sell_shares'))
            children << render_shares('Issue', step.issuable_shares(@entity), Engine::Action::SellShares)
          end
        end

        if @current_actions.include?('buy_shares')
          if (step = @game.round.step_for(@entity, 'buy_shares'))
            children << render_shares('Redeem', step.redeemable_shares(@entity), Engine::Action::BuyShares)
          end
        end

        h('div.margined', children.compact)
      end

      def render_shares(description, shares, action)
        shares = shares.map do |bundle|
          render_button(bundle) do
            process_action(action.new(
              @entity,
              shares: bundle.shares,
              share_price: bundle.share_price,
            ))
          end
        end

        return nil if shares.empty?

        h(:div, [
          h('div.inline-block.margined', description),
          h('div.inline-block', shares),
        ])
      end

      def render_button(bundle, &block)
        str = "#{bundle.num_shares} (#{@game.format_currency(bundle.price)})"
        str += " from #{bundle.owner.name}" if bundle.owner.player?
        h('button.small', { on: { click: block } }, str)
      end
    end
  end
end
