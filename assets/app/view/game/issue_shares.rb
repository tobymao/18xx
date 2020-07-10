# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/undo_and_pass'

module View
  module Game
    class IssueShares < Snabberb::Component
      include Actionable

      def render
        @step = @game.round.active_step
        @entity = @game.current_entity

        h(:div, [
          render_shares('Issue', @step.issuable_shares(@entity), Engine::Action::SellShares),
          render_shares('Redeem', @step.redeemable_shares(@entity), Engine::Action::BuyShares),
        ].compact)
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
          h('div.inline-block', description),
          h('div.inline-block', shares),
        ])
      end

      def render_button(bundle, &block)
        h(
          'button.button',
          { style: { padding: '0.2rem 0.5rem' }, on: { click: block } },
          "#{bundle.num_shares} (#{@game.format_currency(bundle.price)})",
        )
      end
    end
  end
end
