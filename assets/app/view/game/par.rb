# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class Par < Snabberb::Component
      include Actionable

      needs :corporation

      def render
        entity = @game.current_entity
        return h(:div, 'Cannot Par') unless @game.can_par?(@corporation, entity)

        step = @game.round.active_step
        prices = step.get_par_prices(entity, @corporation).sort_by(&:price)

        par_buttons = prices.map do |share_price|
          par = lambda do
            process_action(Engine::Action::Par.new(
              @game.current_entity,
              corporation: @corporation,
              share_price: share_price,
            ))
          end

          props = {
            style: {
              width: 'calc(17.5rem/6)',
              padding: '0.2rem',
            },
            on: { click: par },
          }

          available_cash = if step.respond_to?(:available_par_cash)
                             step.available_par_cash(entity, @corporation, share_price: share_price)
                           else
                             entity.cash
                           end
          # Needed for 1825 minors (where share price is for a 10% share, but certs are 20% and 40%)
          multiplier = @corporation.price_multiplier
          purchasable_shares = [(available_cash / share_price.price).to_i,
                                (@corporation.max_ownership_percent / 100) * @corporation.total_shares * multiplier].min
          purchasable_shares = (purchasable_shares / multiplier).to_i * multiplier
          at_limit = purchasable_shares / multiplier * @corporation.total_shares >= @corporation.max_ownership_percent
          flags = at_limit ? ' L' : ''

          flags += " / #{@game.total_shares_to_float(@corporation, share_price.price)}" if @game.class::VARIABLE_FLOAT_PERCENTAGES

          text = if @corporation.presidents_percent < 100
                   "#{@game.par_price_str(share_price)} (#{purchasable_shares}#{flags})"
                 else
                   @game.par_price_str(share_price)
                 end
          h('button.small.par_price', props, text)
        end

        div_class = par_buttons.size < 5 ? '.inline' : ''
        h(:div, [
          h("div#{div_class}", { style: { marginTop: '0.5rem' } }, 'Par Price: '),
          *par_buttons,
        ])
      end
    end
  end
end
