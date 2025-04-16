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

      def rust_obsolete_schedule
        rust_schedule = Hash.new { |h, k| h[k] = [] }
        obsolete_schedule = Hash.new { |h, k| h[k] = [] }
        @game.depot.trains.group_by(&:name).each do |_name, trains|
          trains.first.variants.each do |name, train_variant|
            Array(train_variant[:rusts_on]).each do |rusts_on|
              rust_schedule[rusts_on].append(name) unless rust_schedule[rusts_on].include?(name)
            end
            Array(train_variant[:obsolete_on]).each do |obsolete_on|
              obsolete_schedule[obsolete_on].append(name) unless obsolete_schedule[obsolete_on].include?(name)
            end
          end
        end
        [rust_schedule, obsolete_schedule]
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

        rust_schedule, obsolete_schedule = rust_obsolete_schedule
        trs = if @game.depot.upcoming.empty?
                'No Upcoming Trains'
              else
                @game.depot.upcoming.reject(&:reserved).group_by(&:name).map do |name, trains|
                  events = []
                  events << h('div.left', "obsoletes #{obsolete_schedule[name].join(', ')}") unless obsolete_schedule[name].empty?
                  events << h('div.left', "rusts #{rust_schedule[name].join(', ')}") unless rust_schedule[name].empty?
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
