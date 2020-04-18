# frozen_string_literal: true

module View
  class Player < Snabberb::Component
    needs :player
    needs :game

    def render_shares
      owned_shares = @player.shares_by_corporation.select { |_corporation, shares| shares.any? }

      return 'Shares: None' if owned_shares.empty?

      shares_div = owned_shares.map do |corporation, shares|
        president = shares.any?(&:president)
        corp_style = {
          background: corporation.color,
          color: 'white',
          padding: '0.25rem'
        }
        h(:div, { style: corp_style }, "#{corporation.name} #{president ? '*' : ''}#{shares.sum(&:percent)}%")
      end
      [h(:div, 'Shares:'), *shares_div]
    end

    def render
      style = {
        display: 'inline-block',
        cursor: 'pointer',
        border: 'solid 1px gainsboro',
        padding: '0.5rem',
        margin: '0.5rem 0.5rem 0 0',
        width: '300px',
        'text-align': 'center',
        'font-weight': 'bold',
        'vertical-align': 'top',
      }

      name_style = {
        border: '1px solid gainsboro',
        padding: '0.5rem',
        'font-size': '150%'
      }

      cash_style = {
        margin: '0.5rem 0'
      }

      shares_title_style = {
        margin: '1rem 0'
      }

      h(:div, { style: style }, [
        h(:div, { style: name_style }, @player.name),
        h(:div, { style: cash_style }, "Cash: #{@game.format_currency(@player.cash)}"),
        h(:div, { style: shares_title_style }, render_shares),
        h(:div, "Companies: #{@player.companies.map(&:name)}"),
      ])
    end
  end
end
