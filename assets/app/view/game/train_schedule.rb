# frozen_string_literal: true

require 'lib/settings'

module View
  module Game
    class TrainSchedule < Snabberb::Component
      include Lib::Settings

      needs :game

      def price_str_class
        max_size = @game.depot.upcoming.group_by(&:name).map do |_name, trains|
          trains.first.names_to_prices.keys.size
        end.max
        max_size == 1 ? '.right' : ''
      end

      def render
        title_props = {
          style: {
            padding: '0.4rem',
            backgroundColor: color_for(:bg2),
            color: color_for(:font2),
            fontStyle: 'italic',
          },
        }
        body_props = {
          style: {
            margin: '0.3rem 0 0.4rem',
            display: 'grid',
            justifyItems: 'center',
          },
        }

        depot = @game.depot
        rust_schedule, obsolete_schedule = depot.rust_obsolete_schedule
        trs = if depot.upcoming.empty?
                'No Upcoming Trains'
              else
                depot.upcoming.group_by(&:name).map do |name, trains|
                  events = []
                  events << h('div.left', "rusts #{rust_schedule[name].join(', ')}") if rust_schedule[name]
                  events << h('div.left', "obsoletes #{obsolete_schedule[name].join(', ')}") if obsolete_schedule[name]
                  tds = [h(:td, @game.info_train_name(trains.first)),
                         h("td#{price_str_class}", @game.info_train_price(trains.first)),
                         h('td.right', "×#{trains.size}")]
                  tds << h('td.right', events) unless events.empty?

                  h(:tr, tds)
                end
              end

        h('div#upcoming_trains.card', [
          h('div.title', title_props, 'Upcoming Trains'),
          h(:div, body_props, [
            h(:table, [h(:tbody, trs)]),
          ]),
        ])
      end
    end
  end
end
