# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/company'

module View
  module Game
    class AcquireCompanies < Snabberb::Component
      include Actionable
      needs :show_other_players, default: nil, store: true
      needs :selected_company, default: nil, store: true

      def render
        @corporation = @game.current_entity

        h(:div, render_companies.compact)
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

        companies = @game.purchasable_companies(@corporation).sort_by do |company|
          [!owned_by_other_player?(@corporation.owner, company) ? 0 : 1, company.value]
        end

        companies_to_buy = companies.map do |company|
          if owned_by_other_player?(@corporation.owner, company) && !@show_other_players
            hidden_companies = true
            next
          end
          children = [h(Company, company: company)]
          children << render_acquire_input if @selected_company == company
          h(:div, props, children)
        end

        button_props = {
          style: {
            margin: '1rem 0 1rem 0',
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

      def render_acquire_input
        selected_company = @selected_company
        acquire_click = lambda do
          acquire = lambda do
            process_action(Engine::Action::AcquireCompany.new(
              @corporation,
              company: selected_company,
            ))
            store(:selected_company, nil, skip: true)
          end

          if selected_company.owner == @corporation.owner || !selected_company.owner
            acquire.call
          else
            check_consent(@corporation, selected_company.owner, acquire)
          end
        end

        props = {
          style: {
            textAlign: 'center',
          },
        }

        button_props = {
          style: {
            margin: '1rem 0 1rem 0',
          },
          on: {
            click: acquire_click,
          },
        }

        h(:div, props, [
          h(:button, button_props, 'Acquire'),
        ])
      end
    end
  end
end
