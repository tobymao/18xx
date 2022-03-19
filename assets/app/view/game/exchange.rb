# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Exchange < Snabberb::Component
      include Actionable

      needs :selected_company, default: nil, store: true

      def render_exchange(share, share_origin)
        step = @game.round.active_step(@selected_company)
        return nil unless share
        return nil if !step.respond_to?(:can_gain?) || !step.can_gain?(@selected_company.owner, share, exchange: true)

        exchange = lambda do
          process_action(Engine::Action::BuyShares.new(@selected_company, shares: share))
          store(:selected_company, nil, skip: true)
        end

        text = ''
        text += "#{@game.exchange_partial_percent(share)}% of " if share.president
        text += "#{share.corporation.name} #{share_origin} share"

        h('button.small', { on: { click: exchange } }, text)
      end

      def render
        return h(:span) unless (ability = @game.abilities(@selected_company, :exchange))

        children = []
        @game.exchange_corporations(ability).each do |corporation|
          ipo_share = corporation.shares.find { |s| !s.president }
          children << render_exchange(ipo_share, @game.ipo_name(corporation)) if ability.from.include?(:ipo)

          if ability.from.include?(:ipo) && @game.exchange_for_partial_presidency? &&
              (presidency_share = corporation.shares.find(&:president))
            children << render_exchange(presidency_share, 'Presidency')
          end

          pool_share = @game.share_pool.shares_by_corporation[corporation]&.first
          children << render_exchange(pool_share, 'Market') if ability.from.include?(:market)

          reserved_share = corporation.reserved_shares&.first
          children << render_exchange(reserved_share, 'Reserved') if ability.from.include?(:reserved)
        end

        h(:div, [
          h('div.inline-block.margined', "Exchange #{@selected_company.name} for:"),
          h('div.inline-block', children.compact),
        ])
      end
    end
  end
end
