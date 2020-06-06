# frozen_string_literal: true

require 'view/stock_market'
require 'lib/color'
require 'view/link'
require 'lib/storage'

module View
  class Spreadsheet < Snabberb::Component
    needs :game
    needs :spreadsheet_sort_by, default: nil
    needs :spreadsheet_sort_order, default: nil

    def render
      @spreadsheet_sort_by = Lib::Storage['spreadsheet_sort_by']
      @spreadsheet_sort_order = Lib::Storage['spreadsheet_sort_order']

      h(:div, { style: {
        overflow: 'auto',
        margin: '0 -1rem',
      } }, [render_table])
    end

    def render_table
      h(:table, { style: {
        margin: '1rem 0 1.5rem 0',
        'text-align': 'center',
      } }, [
        *render_title,
        *render_corporations,
        h(:tr, [
          h(:td, { style: { width: '20px' } }, ''),
          h(:th, { attrs: { colspan: @game.players.size } }, 'Player Finances'),
        ]),
        render_player_cash,
        render_player_privates,
        render_player_worth,
        render_player_certs,
      ])
      # TODO: consider adding OR information (could do both corporation OR revenue and player change in value)
      # TODO: consider adding train availability
    end

    def or_history(corporations)
      corporations.flat_map { |c| c.operating_history.keys }.uniq.sort
    end

    def render_history_titles(corporations)
      or_history(corporations).map { |turn, round| h(:th, "#{turn}.#{round}") }
    end

    def render_history(corporation)
      hist = corporation.operating_history
      if hist.empty?
        # This is a company that hasn't floated yet
        []
      else
        or_history(@game.corporations).map do |x|
          if hist[x]
            props = {
              style: {
                opacity: hist[x].dividend.kind == 'withhold' ? '0.5' : '1.0',
                padding: '0 0.15rem',
              },
            }
            h(:td, props, hist[x].revenue.abs)
          else
            h(:td, '')
          end
        end
      end
    end

    def render_title
      or_history_titles = render_history_titles(@game.corporations)
      props = { style: { padding: '0 0.3rem' } }

      [
        h(:tr, [
          h(:th, { style: { width: '20px' } }, ''),
          h(:th, { attrs: { colspan: @game.players.size } }, 'Players'),
          h(:th, { attrs: { colspan: 2 } }, 'Bank'),
          h(:th, { attrs: { colspan: 2 } }, 'Prices'),
          h(:th, { attrs: { colspan: 4 } }, 'Corporation'),
          h(:th, { style: { width: '20px' } }, ''),
          h(:th, { attrs: { colspan: or_history_titles.size } }, 'OR History'),
          ]),
        h(:tr, [
          h(:th, { style: { width: '20px' } }, [
            h(
              Link,
              href: '',
              click: lambda {
                mark_sort_column('ID')
                toggle_sort_order
              },
              children: 'SYM' + (@spreadsheet_sort_by == 'ID' ? ' ' + sort_order_icon : ''),
              class: ''
            ),
          ]),
          *@game.players.map { |p| h(:th, props, p.name) },
          h(:th, props, 'IPO'),
          h(:th, props, 'Market'),
          h(:th, props, 'IPO'),
          h(:th, props, [
            h(
              Link,
              href: '',
              click: lambda {
                mark_sort_column('SHARE-PRICE')
                toggle_sort_order
              },
              children: 'Market' + (@spreadsheet_sort_by == 'SHARE-PRICE' ? ' ' + sort_order_icon : ''),
              class: ''
            ),
          ]),
          h(:th, props, [
            h(
              Link,
              href: '',
              click: lambda {
                mark_sort_column('CASH')
                toggle_sort_order
              },
              children: 'Cash' + (@spreadsheet_sort_by == 'CASH' ? ' ' + sort_order_icon : ''),
              class: ''
            ),
          ]),
          h(:th, props, [
            h(
              Link,
              href: '',
              click: lambda {
                mark_sort_column('OPERATING-ORDER')
                toggle_sort_order
              },
              children: 'Operating Order' + (@spreadsheet_sort_by == 'OPERATING-ORDER' ? ' ' + sort_order_icon : ''),
              class: ''
            ),
          ]),
          h(:th, props, 'Trains'),
          h(:th, props, 'Tokens'),
          h(:th, props, 'Privates'),
          h(:th, { style: { width: '20px' } }, ''),
          *or_history_titles,
        ]),
      ]
    end

    def sort_order_icon
      return '(⬇️)' if @spreadsheet_sort_order == 'ASC'

      '(⬆️)'
    end

    def mark_sort_column(sort_by)
      Lib::Storage['spreadsheet_sort_by'] = sort_by
      update
    end

    def toggle_sort_order
      Lib::Storage['spreadsheet_sort_order'] = 'ASC' if @spreadsheet_sort_order == 'DESC'
      Lib::Storage['spreadsheet_sort_order'] = 'DESC' unless @spreadsheet_sort_order == 'DESC'
      update
    end

    def render_corporations
      current_round = @game.round.turn_round_num

      ordered_corporations = sorted_corporations
      ordered_corporations.map do |c|
        render_corporation(c[1], c[0], current_round)
      end
    end

    def sorted_corporations
      result = []
      floated_corporations = @game.round.entities

      @game.corporations.map do |c|
        operating_order = (floated_corporations.find_index(c) || -1) + 1
        result << [operating_order, c]
      end

      result = result.sort_by do |c|
        case @spreadsheet_sort_by
        when 'OPERATING-ORDER'
          c[0]
        when 'CASH'
          c[1].cash
        when 'SHARE-PRICE'
          c[1].share_price.nil? ? 0 : c[1].share_price.price
        else
          c[1].id
        end
      end

      result.reverse! if @spreadsheet_sort_order == 'DESC'
      result
    end

    def render_corporation(corporation, operating_order, current_round)
      name_props =
        {
          style: {
            background: corporation.color,
            color: corporation.text_color,
          },
        }

      props = { style: {} }
      market_props = { style: {} }

      if !corporation.floated?
        props[:style]['background-color'] = 'rgba(220,220,220,0.4)'
      elsif !corporation.counts_for_limit && (color = StockMarket::COLOR_MAP[corporation.share_price.color])
        market_props[:style]['background-color'] = Lib::Color.convert_hex_to_rgba(color, 0.4)
      end

      operating_order_text = ''
      if operating_order.positive?
        operating_order_text = operating_order.to_s
        corporation.operating_history.each do |history|
          operating_order_text += '*' if history[0] == current_round
        end
      end

      h(:tr, props, [
        h(:th, name_props, corporation.name),
        *@game.players.map do |p|
          sold_props = { style: {} }
          sold_props[:style]['background-color'] = 'rgba(225,0,0,0.4)' if @game.round.did_sell?(corporation, p)
          h(:td, sold_props, p.num_shares_of(corporation).to_s + (corporation.president?(p) ? '*' : ''))
        end,
        h(:td, corporation.num_shares_of(corporation)),
        h(:td, @game.share_pool.num_shares_of(corporation)),
        h(:td, corporation.par_price ? @game.format_currency(corporation.par_price.price) : ''),
        h(:td, market_props, corporation.share_price ? @game.format_currency(corporation.share_price.price) : ''),
        h(:td, @game.format_currency(corporation.cash)),
        h(:td, operating_order_text),
        h(:td, corporation.trains.map(&:name).join(',')),
        h(:td, "#{corporation.tokens.map { |t| t.used? ? 0 : 1 }.sum}/#{corporation.tokens.size}"),
        render_companies(corporation),
        h(:th, name_props, corporation.name),
        *render_history(corporation),
      ])
    end

    def render_companies(entity)
      h(:td, entity.companies.map(&:short_name).join(','))
    end

    def render_player_privates
      h(:tr, [
        h(:th, 'Privates'),
        *@game.players.map { |p| render_companies(p) },
      ])
    end

    def render_player_cash
      h(:tr, [
        h(:th, 'Cash'),
        *@game.players.map { |p| h(:td, @game.format_currency(p.cash)) },
      ])
    end

    def render_player_worth
      h(:tr, [
        h(:th, 'Worth'),
        *@game.players.map { |p| h(:td, @game.format_currency(p.value)) },
      ])
    end

    def render_player_certs
      h(:tr, [
        h(:th, 'Certs'),
        *@game.players.map { |p| h(:td, p.num_certs) },
      ])
    end
  end
end
