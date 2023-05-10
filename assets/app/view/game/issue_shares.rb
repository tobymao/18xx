# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class IssueShares < Snabberb::Component
      include Actionable
      needs :entity, default: nil

      def emergency?
        return false unless @game.round.active_step.respond_to?(:must_buy_train?)

        @game.round.active_step.must_buy_train?(@entity)
      end

      def render
        @step = @game.round.active_step
        @entity ||= @game.current_entity
        @current_actions = @game.round.actions_for(@entity)
        children = []

        if @current_actions.include?('sell_shares') && (step = @game.round.step_for(@entity, 'sell_shares'))
          issue_text = emergency? ? 'Emergency Issue' : 'Issue'
          issue_text = step.issue_text(@entity) if step.respond_to?(:issue_text)
          children << render_shares(issue_text, step.issuable_shares(@entity), Engine::Action::SellShares)
        end

        if @current_actions.include?('buy_shares') && (step = @game.round.step_for(@entity, 'buy_shares'))
          children << render_shares('Redeem', step.redeemable_shares(@entity), Engine::Action::BuyShares)
        end

        h('div.margined', children.compact)
      end

      def render_shares(description, shares, action)
        shares = shares.map do |bundle|
          render_button(bundle) do
            process_redeem = lambda do
              process_action(action.new(
                @entity,
                shares: bundle.shares,
                share_price: bundle.share_price,
              ))
            end

            # confirm if redeeming from a different player
            if (bundle.owner != @game.bank) && (bundle.owner != @game.current_entity) && bundle.owner.player?
              check_consent(@entity, bundle.owner, process_redeem)
            else
              process_redeem.call
            end
          end
        end

        return nil if shares.empty?

        h(:div, [
          h('div.inline-block.margined', description),
          h('div.inline-block', shares),
        ])
      end

      def render_button(bundle, &block)
        name = if @step.respond_to?(:issue_corp_name)
                 "#{@step.issue_corp_name(bundle)} "
               elsif bundle.owner == @game.bank
                 'IPO '
               else
                 ''
               end

        flags = ('d' * bundle.shares.count(&:double_cert))

        str = "#{flags.empty? ? '' : flags + ' '}#{bundle.num_shares} #{name}(#{@game.format_currency(bundle.price)})"
        str += " from #{bundle.owner.name}" if bundle.owner.player?
        h('button.small', { on: { click: block } }, str)
      end
    end
  end
end
