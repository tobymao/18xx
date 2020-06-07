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
          render_issuable_shares,
          render_redeemable_shares,
        ].compact)
      end

      def render_issuable_shares
        shares = @round.issuable_shares.map do |bundle|
          render_button(bundle) do
            process_action(Engine::Action::SellShares.new(@current_entity, bundle.shares, bundle.percent))
          end
        end

        return nil if shares.empty?

        h(:div, [
          h('div.inline.margined', 'Issue'),
          *shares,
        ])
      end

      def render_redeemable_shares
        shares = @round.redeemable_shares.map do |bundle|
          render_button(bundle) do
            process_action(Engine::Action::BuyShare.new(@current_entity, bundle.shares, bundle.percent))
          end
        end

        return nil if shares.empty?

        h(:div, [
          h('div.inline.margined', 'Redeem'),
          *shares,
        ])
      end

      def render_button(bundle, &block)
        h(
          'button.button',
          { on: { click: block } },
          "#{bundle.num_shares} (#{@game.format_currency(bundle.price)})",
        )
      end
    end
  end
end
