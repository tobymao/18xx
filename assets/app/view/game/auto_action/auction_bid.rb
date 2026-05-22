# frozen_string_literal: true

require 'view/game/auto_action/base'

module View
  module Game
    module AutoAction
      class AuctionBid < Base
        def name
          "Auto bid in Auction Round#{' (Enabled)' if @settings}"
        end

        def description
          if step.programmable_buy_price?
            'Automatically bid, buy or pass in the auction round. '\
              'Bids increase by the minimum increment. '\
              'Buys only when the current price matches your specified price.'
          else
            'Automatically bid or pass in the auction round. '\
              'Bids increase by the minimum increment.'
          end
        end

        def render
          return [] unless @game.round.auction?

          form = {}

          children = [h(:h3, name), h(:p, description)]

          unless selected
            children << h('p.italic', 'No entity currently up for auction.')
            return children
          end

          children << h(Corporation, corporation: selected) if selected&.corporation? || selected&.minor?
          children << h(Company, company: selected) if selected&.company?

          children << h(:div, [render_enable_maximum_bid(form), render_maximum_bid(form)])
          children << h(:div, [render_enable_buy_price(form), render_buy_price(form)]) if step.programmable_buy_price?
          children << h(:div, [render_auto_pass(form)])

          subchildren = [render_button(@settings ? 'Update' : 'Enable') { enable(form) }]
          subchildren << render_disable(@settings) if @settings
          children << h(:div, subchildren)

          children
        end

        def render_enable_maximum_bid(form)
          checked = selected == @settings&.bid_target ? !!@settings&.enable_maximum_bid : false

          render_input('Maximum Bid',
                       id: 'enable_maximum_bid',
                       type: 'checkbox',
                       name: 'mode',
                       inputs: form,
                       attrs: {
                         name: 'mode_options',
                         checked: checked,
                       })
        end

        def render_maximum_bid(form)
          value = selected == @settings&.bid_target ? @settings&.maximum_bid : step.min_bid(selected)
          render_input('',
                       id: 'maximum_bid',
                       type: 'number',
                       inputs: form,
                       attrs: {
                         value: value,
                         step: step.min_increment,
                         min: step.min_bid(selected),
                       }.compact,
                       input_style: { width: '4.25rem' })
        end

        def render_enable_buy_price(form)
          checked = selected == @settings&.bid_target ? !!@settings&.enable_buy_price : false

          render_input('Buy Price',
                       id: 'enable_buy_price',
                       type: 'checkbox',
                       name: 'mode',
                       inputs: form,
                       attrs: {
                         name: 'mode_options',
                         checked: checked,
                       })
        end

        def render_buy_price(form)
          value = selected == @settings&.bid_target ? @settings&.buy_price : 0

          render_input(
            '',
            id: 'buy_price',
            type: 'number',
            inputs: form,
            attrs: {
              value: value,
              step: step.min_increment,
              min: 0,
            },
          )
        end

        def render_auto_pass(form)
          checked = selected == @settings&.bid_target ? !!@settings&.auto_pass_after : false
          label = step.programmable_buy_price? ? 'Pass after max bid reached / buy price impossible' \
                                               : 'Pass after max bid reached'

          render_checkbox(label, 'auto_pass_after', form, checked)
        end

        def enable(form)
          @settings = params(form)

          checked = (step.programmable_buy_price? && @settings['enable_buy_price']) ||
                    @settings['enable_maximum_bid'] || @settings['auto_pass_after']
          return unless checked

          process_action(
            Engine::Action::ProgramAuctionBid.new(
              @sender,
              bid_target: selected,
              enable_maximum_bid: @settings['enable_maximum_bid'],
              maximum_bid: @settings['maximum_bid'] || 0,
              enable_buy_price: @settings['enable_buy_price'],
              buy_price: @settings['buy_price'] || 0,
              auto_pass_after: @settings['auto_pass_after'],
            )
          )
        end

        def step
          @game.round.active_step
        end

        def selected
          step.auctioning || @settings&.bid_target
        end
      end
    end
  end
end
