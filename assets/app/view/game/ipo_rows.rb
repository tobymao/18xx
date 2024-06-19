# frozen_string_literal: true

require 'lib/settings'
require 'view/game/company'
require 'view/game/actionable'

module View
  module Game
    class IpoRows < Snabberb::Component
      include Lib::Settings
      include Actionable

      needs :game, store: true
      needs :display, default: 'inline-block'
      needs :selected_company, default: nil, store: true
      needs :show_first, default: true

      def render
        @owner = @game.bank
        ipo_rows = @game.ipo_rows

        round = @game.round
        @step = round.active_step
        @current_entity = @step.current_entity
        @current_actions = round.actions_for(@current_entity)

        ipo_rows.map.with_index do |ipo_row, index|
          h(:span, [render_ipo_row(ipo_row, index + 1)])
        end
      end

      def render_ipo_row(ipo_row, number)
        card_style = {
          border: '1px solid gainsboro',
          paddingBottom: '0.2rem',
        }
        card_style[:display] = @display

        companies = ipo_row.dup
        return h(:div) if companies.empty?

        divs = [render_title(number)]
        divs << render_first_ipo(companies) if @show_first
        divs << h(CompaniesTable, game: @game, companies: companies) unless companies.empty?

        h('div.player.card', { style: card_style }, divs)
      end

      def render_title(number)
        bg_color = color_for(:bg2)
        props = {
          style: {
            padding: '0.4rem',
            backgroundColor: bg_color,
            color: contrast_on(bg_color),
          },
        }

        h('div.player.title.nowrap', props, ["IPO Row #{number}"])
      end

      def render_first_ipo(ipo_row)
        button_props = {
          style: {
            display: 'grid',
            gridColumn: '1/4',
            width: 'max-content',
          },
        }
        first_company = ipo_row.shift
        inputs = []
        inputs.concat(render_buy_input(first_company)) if @current_actions.intersect?(%w[buy_company corporate_buy_company])
        children = []
        children << h(Company, company: first_company, interactive: !inputs.empty?)
        children << h('div.margined_bottom', button_props, inputs) if !inputs.empty? && @selected_company == first_company
        h(:div, children)
      end

      def render_buy_input(company)
        return [] unless @step.can_buy_company?(@current_entity, company)

        action = @current_actions.include?('buy_company') ? Engine::Action::BuyCompany : Engine::Action::CorporateBuyCompany
        buy = lambda do
          process_action(action.new(
            @current_entity,
            company: company,
            price: company.value,
          ))
          store(:selected_company, nil, skip: true)
        end
        [h(:button,
           { on: { click: buy } },
           "Buy #{company.name} from IPO Row for #{@game.format_currency(company.value)}")]
      end
    end
  end
end
