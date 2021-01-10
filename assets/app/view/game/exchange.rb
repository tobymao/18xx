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

        text =
          if share.president
            text = "#{100 / share.num_shares}% of #{share.corporation.name} Presidency"
          end

        h('button.small', { on: { click: exchange } }, text || "#{share.corporation.name} #{share_origin} share")
      end

      def render
        return h(:span) unless (ability = @game.abilities(@selected_company, :exchange))

        children = []
        corporations =
          ability.corporation == 'any' ? @game.corporations : [@game.corporation_by_id(ability.corporation)]
        corporations.each do |corporation|
          ipo_share = corporation.shares.find { |s| !s.president }
          children << render_exchange(ipo_share, @game.ipo_name(corporation)) if ability.from.include?(:ipo)

          if !corporation.ipoed# && ability.allow_partial_presidency && can_par?
            children << render_exchange(corporation.shares.find(&:president), 'Presidency')
          end

          pool_share = @game.share_pool.shares_by_corporation[corporation]&.first
          children << render_exchange(pool_share, 'Market') if ability.from.include?(:market)
        end

        h(:div, [
          h('div.inline-block.margined', "Exchange #{@selected_company.name} for:"),
          h('div.inline-block', children.compact),
        ])
      end
    end
  end
end
