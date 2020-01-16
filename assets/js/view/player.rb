# frozen_string_literal: true

module View
  class Player < Snabberb::Component
    needs :player

    def render
      style = {
        border: 'solid 1px rgba(0,0,0,0.2)',
        display: 'inline-block',
      }

      shares_div = @player.shares_by_corporation.map do |corporation, shares|
        president = shares.any?(&:president)
        h(:div, "#{corporation.name} #{president ? '*' : ''}#{shares.map(&:percent).sum}%")
      end

      h(:div, { style: style }, [
        h(:div, "name: #{@player.name}"),
        h(:div, "cash: #{@player.cash}"),
        h(:div, "companies: #{@player.companies.map(&:name)}"),
        *shares_div,
      ])
    end
  end
end
