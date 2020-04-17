# frozen_string_literal: true

module View
  class Player < Snabberb::Component
    needs :player
    needs :game, store: true

    def render
      style = {
        border: 'solid 1px rgba(0,0,0,0.2)',
        padding: '3px',
        margin: '3px',
        display: 'inline-block',
      }

      if @game.round.can_act?(@player)
        style['border'] = 'solid 1px rgba(0,0,0)'
        style['background-color'] = '#dfd'
      end

      table_style = {
        display: 'table',
        'margin-left': 'auto',
        'margin-right': 'auto'
      }

      row_style = {
        display: 'table-row'
      }

      cell1_style = {
        display: 'table-cell',
        'text-align': 'right',
        'padding-right': '5px'
      }

      cell2_style = {
        display: 'table-cell',
        'text-align': 'right',
        'padding-left': '5px'
      }

      cell3_style = {
        display: 'table-cell',
        'text-align': 'left',
        'padding-left': '5px'
      }

      shares_div = @player.shares_by_corporation.map do |corporation, shares|
        president = shares.any?(&:president)
        h(:div, { style: row_style }, [
            h(:div, { style: cell1_style }, corporation.sym.to_s),
            h(:div, { style: cell2_style }, "#{shares.sum(&:percent)}%"),
            h(:div, { style: cell3_style }, president ? '(president)' : '')
        ])
      end

      name_style = {
        background: '#bdb',
        border: '1px solid',
        'margin-bottom': '0.5rem',
        'font-weight': '700',
        'text-align': 'center'
      }

      h(:div, { style: style }, [
        h(:div, { style: name_style }, @player.name.to_s),
        h(:div, "cash: #{@game.format_currency(@player.cash)}"),
        h(:div, "companies: #{@player.companies.map(&:name)}"),
        h(:div, { style: table_style }, shares_div)
      ])
    end
  end
end
