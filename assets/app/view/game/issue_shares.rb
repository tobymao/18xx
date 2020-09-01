# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class IssueShares < Snabberb::Component
      include Actionable

      def render
        @step = @game.round.active_step
        @entity = @game.current_entity

        children = []

        if @step.current_actions.include?('sell_shares')
          children << render_shares('Issue', @step.issuable_shares(@entity), Engine::Action::SellShares)
        end

        if @step.current_actions.include?('buy_shares')
          children << render_shares('Redeem', @step.redeemable_shares(@entity), Engine::Action::BuyShares)
        end

        h(:div, children.compact)
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

        h('div.margined', [
          h('div.inline-block.margined', description),
          h('div.inline-block', shares),
        ])
      end

      def render_button(bundle, &block)
        h('button.small', { on: { click: block } }, "#{bundle.num_shares} (#{@game.format_currency(bundle.price)})")
      end
    end
  end
end
