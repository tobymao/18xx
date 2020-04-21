# frozen_string_literal: true

module View
  class TrainRoster < Snabberb::Component
    needs :game

    def render
      @depot = @game.depot

      h(:div, {}, [
        render_body
      ])
    end

    def render_body
      children = [h(:div, [upcoming_trains])]

      unless @depot.discarded.empty?
        props = {
          style: {
            'margin-top': '1rem',
          },
        }

        children << h(:div, props, [
          discarded_trains,
        ])
      end

      h(:div, {}, children)
    end

    def upcoming_trains
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

    def discarded_trains
      td_props = {
        style: {
          padding: '0 1rem'
        }
      }

      rows = @depot.discarded.map do |train|
        h(:tr, [
          h(:td, td_props, train.name),
          h(:td, td_props, @game.format_currency(train.price)),
        ])
      end

      h(:div, [
        h(:div, 'In bank pool:'),
        h(:table, [
          h(:tr, [
            h(:th, td_props, 'Type'),
            h(:th, td_props, 'Price'),
          ]),
          *rows
        ])
      ])
    end
  end
end
