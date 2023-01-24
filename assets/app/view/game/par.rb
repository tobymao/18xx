# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Par < Snabberb::Component
      include Actionable

      needs :corporation
      needs :corporation_to_par, default: nil, store: true

      def render_inline_selection(target)
        target_cash = target ? target.cash : 0
        if target
          return [] unless @step.respond_to?(:get_par_prices_with_help)

          prices = @step.get_par_prices_with_help(@current_entity, @corporation, extra_cash: target_cash).sort_by(&:price)
        else
          prices = @step.get_par_prices(@current_entity, @corporation).sort_by(&:price)
        end

        par_buttons = prices.map do |share_price|
          par = lambda do
            process_action(Engine::Action::Par.new(
              @current_entity,
              corporation: @corporation,
              share_price: share_price,
              purchase_for: target,
              borrow_from: target ? @current_entity : nil,
            ))
          end

          props = {
            style: {
              width: 'calc(17.5rem/6)',
              padding: '0.2rem',
            },
            on: { click: par },
          }

          available_cash = if @step.respond_to?(:available_par_cash)
                             @step.available_par_cash(@current_entity, @corporation, share_price: share_price)
                           else
                             @current_entity.cash + target_cash
                           end
          # Needed for 1825 minors (where share price is for a 10% share, but certs are 20% and 40%)
          multiplier = @corporation.price_multiplier
          purchasable_shares = [(available_cash / share_price.price).to_i,
                                (@corporation.max_ownership_percent / 100) * @corporation.total_shares * multiplier].min
          purchasable_shares = (purchasable_shares / multiplier).to_i * multiplier
          at_limit = purchasable_shares / multiplier * @corporation.total_shares >= @corporation.max_ownership_percent
          flags = at_limit ? ' L' : ''

          flags += " / #{@game.total_shares_to_float(@corporation, share_price.price)}" if @game.class::VARIABLE_FLOAT_PERCENTAGES
          no_shares = @step.respond_to?(:par_price_only) && @step.par_price_only(@corporation, share_price)

          text = if @corporation.presidents_percent < 100 && !no_shares
                   "#{@game.par_price_str(share_price)} (#{purchasable_shares}#{flags})"
                 else
                   @game.par_price_str(share_price)
                 end
          h('button.small.par_price', props, text)
        end

        div_class = par_buttons.size < 5 ? '.inline' : ''
        par_str = target ? "Par for #{target.name}: " : 'Par Price: '
        [h(:div, [
          h("div#{div_class}", { style: { marginTop: '0.5rem' } }, par_str),
          *par_buttons,
        ])]
      end

      def render_par_from_par_chart
        props = {
          style: {
            width: 'calc(17.5rem/6)',
            padding: '0.2rem',
          },
          on: { click: -> { store(:corporation_to_par, @corporation) } },
        }
        button = h('button.small.par_price', props, 'Par')

        [h('div.inline', { style: { marginTop: '0.5rem' } }, [button])]
      end

      def render_par(target = nil)
        return [h(:div, 'Cannot Par')] unless @game.can_par?(@corporation, @current_entity)

        if @game.respond_to?(:par_chart)
          render_par_from_par_chart
        else
          render_inline_selection(target)
        end
      end

      def render_par_for_others
        return [] unless @step.respond_to?(:can_buy_for)

        targets = @step.can_buy_for(@current_entity)

        targets.flat_map do |target|
          render_par(target)
        end
      end

      def render
        @step = @game.round.active_step
        @current_entity = @step.current_entity

        children = []
        children.concat(render_par)
        children.concat(render_par_for_others)
        return h(:div, children) unless children.empty?

        nil
      end
    end
  end
end
