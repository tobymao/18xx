# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/company'

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

      def render_companies
        hidden_companies = false
        props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }

        companies = @game.purchasable_companies.sort_by do |company|
          [company.owner == @corporation.owner ? 0 : 1, company.value]
        end

        companies_to_buy = companies.map do |company|
          if company.owner != @corporation.owner && !@show_other_players
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
        input = h(:input, style: { marginRight: '1rem' }, props: {
          value: @selected_company.max_price,
          type: 'number',
          min: @selected_company.min_price,
          max: @selected_company.max_price,
          size: @corporation.cash.to_s.size,
        })

        buy_click = lambda do
          price = input.JS['elm'].JS['value'].to_i
          buy = lambda do
            process_action(Engine::Action::BuyCompany.new(
              @corporation,
              company: @selected_company,
              price: price,
            ))
            store(:selected_company, nil, skip: true)
          end

          if !@selected_company.owner || @selected_company.owner == @corporation.owner
            buy.call
          else
            check_consent(@selected_company.owner, buy)
          end
        end

        props = {
          style: {
            textAlign: 'center',
            margin: '1rem',
          },
        }

        h(:div, props, [
          input,
          h(:button, { on: { click: buy_click } }, 'Buy'),
        ])
      end
    end
  end
end
