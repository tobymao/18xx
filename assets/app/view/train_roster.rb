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
      children = [h(:div, [cert_limit, upcoming_trains])]

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

      children << phases

      h(:div, {}, children)
    end

    def cert_limit
      cert_props = {
        style: {
          'margin-bottom': '1rem'
        }
      }
      h(:div, cert_props, "Certificate limit: #{@game.cert_limit}")
    end

    def phases
      td_props = {
        style: {
          padding: '0 1rem'
        }
      }

      current_phase = @game.phase.current
      rows = @game.phase.phases.map do |phase|
        phase_color = Array(phase[:tiles]).last
        phase_props = {
          style: {
            padding: '0 1rem'
          }
        }
        if View::Part::MultiRevenue::COLOR.include? phase_color
          m = View::Part::MultiRevenue::COLOR[phase_color].match(/#(..)(..)(..)/)
          phase_props[:style]['background-color'] = "rgba(#{m[1].hex},#{m[2].hex},#{m[3].hex},0.4)"
        end

        buy_text = if phase[:buy_companies]
                     'Can Buy'
                   elsif phase[:events]&.include?(:close_companies)
                     'Close'
                   else
                     ''
                   end

        h(:tr, [
          h(:td, td_props, phase[:name] + (current_phase == phase ? ' (Current) ' : '')),
          h(:td, td_props, phase[:operating_rounds]),
          h(:td, td_props, phase[:train_limit]),
          h(:td, phase_props, phase_color.capitalize),
          h(:td, td_props, buy_text)
        ])
      end

      props = {
        style: { 'margin-top': '1rem' }
      }
      h(:div, props, [
        h(:div, 'Game Phases'),
        h(:table, [
          h(:tr, [
            h(:th, td_props, 'Phase'),
            h(:th, td_props, 'Operating Rounds'),
            h(:th, td_props, 'Train Limit'),
            h(:th, td_props, 'Tiles'),
            h(:th, td_props, 'Companies')
          ]),
          *rows
        ])
      ])
    end

    def upcoming_trains
      td_props = {
        style: {
          padding: '0 1rem'
        }
      }

      rust_schedule = {}
      @depot.trains.group_by(&:name).each do |name, trains|
        rust_schedule[trains.first.rusts_on] = Array(rust_schedule[trains.first.rusts_on]).append(name)
      end

      rows = @depot.upcoming.group_by(&:name).map do |name, trains|
        train = trains.first
        discounts = train.discount&.group_by { |_k, v| v }&.map do |price, price_discounts|
          price_discounts.map(&:first).join(',') + ' => ' + @game.format_currency(price)
        end
        h(:tr, [
          h(:td, td_props, name),
          h(:td, td_props, @game.format_currency(train.price)),
          h(:td, td_props, trains.size),
          h(:td, td_props, rust_schedule[name]&.join(',') || 'None'),
          h(:td, td_props, discounts&.join(' '))
        ])
      end

      h(:div, [
        h(:div, 'Upcoming Trains'),
        h(:table, [
          h(:tr, [
            h(:th, td_props, 'Type'),
            h(:th, td_props, 'Price'),
            h(:th, td_props, 'Remaining'),
            h(:th, td_props, 'Rusts'),
            h(:th, td_props, 'Upgrade Discount')
          ]),
          *rows
        ])
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
