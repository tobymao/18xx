# frozen_string_literal: true

require 'view/game/actionable'

module View
  module Game
    class BorrowTrain < Snabberb::Component
      include Actionable
      needs :corporation, default: nil
      def render
        step = @game.round.active_step
        @corporation ||= step.current_entity
        @ability = @game.abilities(@selected_company, :borrow_train)

        @depot = @game.depot

        available = step.borrowable_trains(@corporation)
        children = []

        h3_props = {
          style: {
            margin: '0.5rem 0 0 0',
          },
        }
        div_props = {
          style: {
            display: 'grid',
            grid: 'auto / minmax(0.7rem, auto) auto',
            gap: '0.5rem',
            alignItems: 'center',
          },
        }

        if step.can_borrow_train?(@corporation)
          children << h(:div, "#{@corporation.name} may borrow an available train")
          children << h(:h3, h3_props, 'Available Trains')
          children << h(:div, div_props, [
            *from_depot(available),
          ])
        end

        children << h(:h3, h3_props, 'Remaining Trains')
        children << remaining_trains

        props = {
          style: {
            display: 'grid',
            rowGap: '0.5rem',
            marginBottom: '1rem',
          },
        }

        h('div#borrow_train', props, children)
      end

      def from_depot(depot_trains)
        depot_trains.flat_map do |train|
          borrow_train = lambda do
            process_action(Engine::Action::BorrowTrain.new(@corporation, train: train))
          end

          [
            h(:div, train.name),
            h('button.no_margin', { on: { click: borrow_train } }, 'Borrow'),
          ]
        end
      end

      def remaining_trains
        div_props = {
          style: {
            display: 'grid',
            grid: 'auto / repeat(3, max-content)',
            gap: '0 1rem',
            justifyItems: 'right',
          },
        }

        rows = @depot.upcoming.group_by(&:name).flat_map do |_, trains|
          names_to_prices = trains.first.names_to_prices
          [h(:div, names_to_prices.keys.join(', ')),
           h(:div, names_to_prices.values.map { |p| @game.format_currency(p) }.join(', ')),
           h(:div, trains.size)]
        end

        h(:div, div_props, [
          h('div.bold', 'Train'),
          h('div.bold', 'Cost'),
          h('div.bold', 'Qty'),
          *rows,
        ])
      end
    end
  end
end
