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
        needs :percentages_available, default: 1
        needs :prefix, default: 'Buy'
        needs :source, default: 'Market'
        needs :action, default: Engine::Action::BuyShares

        def render
          show_percentage = @percentages_available > 1 ||
                            @share.percent != @share.corporation.share_percent && !@share.president
          reduced_price = @game.format_currency(@share.price - @swap_share.price) if @swap_share

          text = @prefix.to_s
          text += " #{@share.percent}%" if show_percentage
          text += " #{@source} Share"
          text += " (#{reduced_price} + #{@swap_share.percent}% Share)" if @swap_share

          h(:button, { on: { click: -> { buy_share(@entity, @share, swap: @swap_share) } } }, text)
        end

        def buy_share(entity, share, swap: nil)
          process_action(@action.new(entity, shares: share, swap: swap))
        end
      end
    end
  end
end
