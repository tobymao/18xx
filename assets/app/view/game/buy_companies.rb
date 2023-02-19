# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/company'
require 'view/game/buy_value_input'

module View
  module Game
    class BuyCompanies < Snabberb::Component
      include Actionable
      needs :show_other_players, default: nil, store: true
      needs :selected_company, default: nil, store: true
      needs :limit_width, default: false

      def render
        @corporation = @game.current_entity
        props = @limit_width ? { style: { flexGrow: '1', width: '0' } } : {}

        h(:div, props, [
          *render_companies,
        ].compact)
      end

      def owned_by_other_player?(player, company)
        return false unless company&.owner # Bank owned, not a player

        player != company&.owner
      end

      def render_companies
        hidden_companies = false
        props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }

        companies = @game.purchasable_companies.sort_by do |company|
          [!owned_by_other_player?(@corporation.owner, company) ? 0 : 1, company.value]
        end

        companies_to_buy = companies.map do |company|
          if owned_by_other_player?(@corporation.owner, company) && !@show_other_players
            hidden_companies = true
            next
          end
          children = [h(Company, company: company)]
          children << render_input if @selected_company == company
          h(:div, props, children)
        end

        button_props = {
          style: {
            display: 'grid',
            gridColumn: '1/4',
            width: 'max-content',
          },
        }

        if hidden_companies
          companies_to_buy << h('button.no_margin',
                                { on: { click: -> { store(:show_other_players, true) } }, **button_props },
                                'Show companies from other players')
        elsif @show_other_players
          companies_to_buy << h('button.no_margin',
                                { on: { click: -> { store(:show_other_players, false) } }, **button_props },
                                'Hide companies from other players')
        end
        companies_to_buy.compact
      end

      def render_input
        step = @game.round.step_for(@corporation, 'buy_company')
        buyer = if step.respond_to?(:spender)
                  step.spender(@corporation)
                else
                  @corporation
                end
        max_price = max_purchase_price(buyer, @selected_company)

        h(BuyValueInput, value: max_price, min_value: @selected_company.min_price,
                         max_value: max_price,
                         size: buyer.cash.to_s.size,
                         selected_entity: @selected_company)
      end

      def max_purchase_price(corporation, company)
        [company.max_price(corporation), corporation.cash].min
      end
    end
  end
end
