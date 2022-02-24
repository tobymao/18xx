# frozen_string_literal: true

require 'view/game/auto_action/base'

module View
  module Game
    module AutoAction
      class AuctionBid < Base
        needs :bid_target, store: true, default: nil

        def name
          "Auto bid in Auction Round#{' (Enabled)' if @settings}"
        end

        def description
          'Automatically bid, buy or pass in the auction round. '\
            'Bids increase by the minimum increment. '\
            'Buys only when the current price matches your specified price.'
        end

        def render
          return [] unless @game.round.auction?

          form = {}

          children = [h(:h3, name), h(:p, description), h(:div, [render_entity_selector(form)])]

          children << h(Corporation, corporation: selected) if selected&.corporation? || selected&.minor?
          children << h(Company, company: selected) if selected&.company?

          children << h(:div, [render_enable_maximum_bid(form), render_maximum_bid(form)])
          children << h(:div, [render_enable_buy_price(form), render_buy_price(form)])
          children << h(:div, [render_auto_pass(form)])

          subchildren = [render_button(@settings ? 'Update' : 'Enable') { enable(form) }]
          subchildren << render_disable(@settings) if @settings
          children << h(:div, subchildren)

          children
        end

        def render_entity_selector(form)
          bid_target_change = lambda do
            target = Native(form[:bid_target]).elm&.value
            bid_target = @game.corporation_by_id(target) || @game.company_by_id(target) || @game.minor_by_id(target)
            store(:bid_target, bid_target)
          end

          render_input('Bid Target',
                       id: 'bid_target',
                       el: 'select',
                       on: { input: bid_target_change },
                       children: values, inputs: form)
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
                       })
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

          render_checkbox('Pass after max bid reached / buy price impossible  ',
                          'auto_pass_after',
                          form,
                          checked)
        end

        def enable(form)
          @settings = params(form)

          bid_target = @game.corporation_by_id(@settings['bid_target']) ||
                        @game.company_by_id(@settings['bid_target']) ||
                        @game.minor_by_id(@settings['bid_target'])

          checked = @settings['enable_buy_price'] || @settings['enable_maximum_bid'] || @settings['auto_pass_after']
          return unless checked

          process_action(
            Engine::Action::ProgramAuctionBid.new(
              @sender,
              bid_target: bid_target,
              enable_maximum_bid: @settings['enable_maximum_bid'],
              maximum_bid: @settings['maximum_bid'],
              enable_buy_price: @settings['enable_buy_price'],
              buy_price: @settings['buy_price'],
              auto_pass_after: @settings['auto_pass_after'],
            )
          )
        end

        def available_targets
          step.available
        end

        def step
          @game.round.active_step
        end

        def selected
          @bid_target || @settings&.bid_target || available_targets.first
        end

        def values
          available_targets.map do |entity|
            attrs = { value: entity.id }
            attrs[:selected] = true if selected == entity
            h(:option, { attrs: attrs }, entity.name)
          end
        end
      end
    end
  end
end
