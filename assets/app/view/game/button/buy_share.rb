# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    module Button
      class BuyShare < Snabberb::Component
        include Actionable

        needs :share
        needs :entity
        needs :swap_share, default: nil
        needs :partial_percent, default: nil
        needs :percentages_available, default: 1
        needs :prefix, default: 'Buy'
        needs :source, default: 'Market'
        needs :action, default: Engine::Action::BuyShares

        def render
          bundle = @share.to_bundle
          show_percentage = @percentages_available > 1 ||
                            bundle.percent != bundle.corporation.share_percent && !bundle.presidents_share
          reduced_price = @game.format_currency(bundle.price - @swap_share.price) if @swap_share

          text = @prefix.to_s
          text += " #{@partial_percent}% of" if @partial_percent
          text += " #{bundle.percent}%" if show_percentage
          text += " #{@source} Share"
          text += " (#{reduced_price} + #{@swap_share.percent}% Share)" if @swap_share

          h(:button, { on: { click: -> { buy_shares(@entity, bundle, swap: @swap_share) } } }, text)
        end

        def buy_shares(entity, bundle, swap: nil)
          process_action(@action.new(entity, shares: bundle.shares, swap: swap))
        end
      end
    end
  end
end
