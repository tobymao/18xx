# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/undo_and_pass'

module View
  module Game
    class IssueShares < Snabberb::Component
      include Actionable

      def render
        @round = @game.round

        h(:div, [
          h(UndoAndPass),
          render_shares('Issue', @round.issuable_shares, Engine::Action::SellShares),
          render_shares('Redeem', @round.redeemable_shares, Engine::Action::BuyShares),
        ].compact)
      end

      def render_shares(description, shares, action)
        shares = shares.map do |bundle|
          render_button(bundle) do
            process_action(action.new(
              @round.current_entity,
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
