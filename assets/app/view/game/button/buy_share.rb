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
        needs :purchase_for, default: nil
        needs :borrow_from, default: nil

        def render
          step = @game.round.active_step
          bundle = @share.to_bundle
          show_percentage = @percentages_available > 1 ||
                            (bundle.percent != bundle.corporation.share_percent && !bundle.presidents_share)
          reduced_price = @game.format_currency(bundle.price - @swap_share.price) if @swap_share
          modified_price = step.respond_to?(:modify_purchase_price) && step.modify_purchase_price(bundle)

          text = @prefix.to_s
          text += " #{@partial_percent}% of" if @partial_percent
          text += " #{bundle.percent}%" if show_percentage
          text += " #{@source} Share"
          text += " (#{reduced_price} + #{@swap_share.percent}% Share)" if @swap_share
          text += " (#{@game.format_currency(modified_price)})" if modified_price
          text += " for #{@purchase_for.name}" if @purchase_for

          h(:button, {
              on: {
                click: lambda {
                  buy_shares(@entity, bundle, share_price: modified_price, swap: @swap_share,
                                              purchase_for: @purchase_for, borrow_from: @borrow_from)
                },
              },
            }, text)
        end

        def buy_shares(entity, bundle, share_price: nil, swap: nil, purchase_for: nil, borrow_from: nil)
          process_action(@action.new(entity, shares: bundle.shares, swap: swap, purchase_for: purchase_for,
                                             share_price: share_price, borrow_from: borrow_from))
        end
      end
    end
  end
end
