# frozen_string_literal: true

require 'view/game/auto_action/base'

module View
  module Game
    module AutoAction
      class BuyShares < Base
        needs :buy_corporation, store: true, default: nil

        def name
          "Auto Buy Shares#{' (Enabled)' if @settings}"
        end

        def description
          'Automatically buy shares in a corporation.'\
            ' This will deactivate itself if other players do actions that may impact you.'\
            ' It will also deactivate if there are multiple share sizes (5%, 10%, 20%)'\
            ' available for purchase.'
        end

        def render
          form = {}
          children = [h(:h3, name), h(:p, description)]

          if buyable.empty?
            children << h('p.bold', 'No corporations have shares available to buy, cannot program!')
            return children
          end

          children << h(:div, render_corporation_selector(form))
          children << h(Corporation, corporation: selected)

          first_radio = !checked?

          # Because the program does not deactivate it could be there
          # is nothing left in the ipo/market/float. Show it anyway
          # if it is activated

          float = render_until_float(form, first_radio)
          children << float if float

          first_radio = false if float
          ipo = render_ipo(form, first_radio)
          children << ipo if ipo

          first_radio = false if ipo || float
          market = render_market(form, first_radio)
          children << market if market

          children << render_auto_pass(form, @settings)

          subchildren = [render_button(@settings ? 'Update' : 'Enable') { enable(form) }]
          subchildren << render_disable(@settings) if @settings
          children << h(:div, subchildren)

          children
        end

        def render_until_float(form, first_radio)
          return if selected.floated? && checked? != :float

          # There is a settings and it's floated, otherwise true if not selected already
          h(:div, [render_input('Until float',
                                id: 'float',
                                type: 'radio',
                                name: 'mode',
                                inputs: form,
                                attrs: {
                                  name: 'mode_options',
                                  checked: first_radio || checked? == :float,
                                })])
        end

        def render_ipo(form, first_radio)
          return if selected.ipo_shares.empty? && checked? != :from_ipo

          render_share_choice(form,
                              selected.ipo_shares,
                              'ipo',
                              @game.ipo_name(selected),
                              first_radio || checked? == :from_ipo)
        end

        def render_market(form, checked)
          return if @game.share_pool.shares_by_corporation[selected].empty? && checked? != :from_market

          checked = (corp_settings&.until_condition != 'float' && corp_settings&.from_market) if corp_settings

          render_share_choice(form,
                              @game.share_pool.shares_by_corporation[selected],
                              'market',
                              'Market',
                              checked)
        end

        def render_auto_pass(form, _settings)
          render_checkbox('Switch to auto-pass after successful completion.',
                          'auto_pass_after',
                          form,
                          !!@settings&.auto_pass_after)
        end

        def render_corporation_selector(form)
          values = buyable.map do |entity|
            attrs = { value: entity.name }
            attrs[:selected] = true if selected == entity
            h(:option, { attrs: attrs }, entity.name)
          end
          buy_corp_change = lambda do
            corp = Native(form[:corporation]).elm&.value
            store(:buy_corporation, @game.corporation_by_id(corp))
          end

          [render_input('Corporation',
                        id: 'corporation',
                        el: 'select',
                        on: { input: buy_corp_change },
                        children: values, inputs: form)]
        end

        def render_share_choice(form, shares, name, print_name, checked)
          owned = @sender.num_shares_of(selected, ceil: false)
          default_value = owned + 1
          default_value = @settings&.until_condition if checked && @settings && @settings&.until_condition != 'float'

          input = render_buy_from_input(print_name, name, form, owned, owned + shares.size, default_value)

          h(:div, render_shares_input(input, name, form, checked))
        end

        def render_buy_from_input(print_name, name, form, min, max, val)
          render_input(
            "Buy from #{print_name} until at ",
            id: "buy_#{name}",
            type: :number,
            inputs: form,
            attrs: {
              min: min,
              max: max,
              value: val,
              required: true,
            },
            input_style: { width: '5rem' },
            container_style: { margin: '0' },
          )
        end

        def render_shares_input(input, name, form, checked)
          [render_input([input, 'share(s)'],
                        id: name,
                        type: 'radio',
                        name: 'mode',
                        inputs: form,
                        attrs: {
                          name: 'mode_options',
                          checked: checked,
                        })]
        end

        def enable(form)
          @settings = params(form)

          corporation = @game.corporation_by_id(@settings['corporation'])
          auto_pass_after = @settings['auto_pass_after']

          until_condition, from_market = conditions

          process_action(
            Engine::Action::ProgramBuyShares.new(
              @sender,
              corporation: corporation,
              until_condition: until_condition,
              from_market: from_market,
              auto_pass_after: auto_pass_after,
            )
          )
        end

        def conditions
          return ['float', false] if @settings['float']
          return [@settings['buy_ipo'].to_i, false] if @settings['ipo']
          return [@settings['buy_market'].to_i, true] if @settings['market']

          [0, true]
        end

        def checked?
          return :float if corp_settings&.until_condition == 'float'
          return :from_market if corp_settings&.from_market
          return :from_ipo if corp_settings

          nil
        end

        def selected
          @buy_corporation || @settings&.corporation || buyable.first
        end

        def corp_settings
          return unless selected == @settings&.corporation

          @settings
        end

        def buyable
          @game.corporations.select do |corp|
            corp.ipoed && (!corp.ipo_shares.empty? || !@game.share_pool.shares_by_corporation[corp].empty?)
          end
        end
      end
    end
  end
end
