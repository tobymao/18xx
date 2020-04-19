# frozen_string_literal: true

module View
  class TrainRoster < Snabberb::Component
    needs :game, store: true

    def render
      @depot = @game.depot

      h(:div, {}, [
        render_body
      ])
    end

    def render_body
      props = {
        style: {
          'margin-top': '1rem',
        },
      }

      h(:div, props, [
        remaining_trains
      ])
    end

    def remaining_trains
      td_props = {
        style: {
          padding: '0 1rem'
        }
      }

      rows = @depot.upcoming.group_by(&:name).map do |name, trains|
        train = trains.first
        h(:tr, [
            h(:td, td_props, name),
            h(:td, td_props, @game.format_currency(train.price)),
            h(:td, td_props, trains.size),
          ])
      end

      h(:table, [
        h(:tr, [
          h(:th, td_props, 'Type'),
          h(:th, td_props, 'Price'),
          h(:th, td_props, 'Remaining'),
        ]),
        *rows
      ])
    end
  end
end
