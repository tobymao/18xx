# frozen_string_literal: true

module View
  module Game
    class Abilities < Snabberb::Component
      needs :game
      needs :user, default: nil
      needs :selected_company, default: nil, store: true
      needs :show_other_abilities, default: false, store: true

      ABILITIES = %i[tile_lay teleport assign_hexes assign_corporation token exchange].freeze

      def render
        companies = @game.companies.select { |company| !company.closed? && actions_for(company).any? }
        return h(:div) if companies.empty?

        current, others = companies.partition { |company| @game.current_entity.owner == company.owner.owner }

        children = [
          h('h3.inline.bold', 'Abilities'),
          *render_companies(current),
        ]

        if others.any?
          others.sort! { |company| company.owner.owner.name == @user&.dig(:name) ? 0 : 1 }

          toggle_show = lambda do
            store(:selected_company, nil, skip: true)
            store(:show_other_abilities, !@show_other_abilities)
          end

          button_props = {
            style: { margin: '0 0 0 1rem' },
            on: { click: toggle_show },
          }
          children << h('button.button', button_props, @show_other_abilities ? 'Hide' : 'Show Others')
          children.concat(render_companies(others)) if @show_other_abilities
        end

        props = { style: { margin: '1rem 0 0.5rem 0' } }
        h(:div, props, children)
      end

      def render_companies(companies)
        companies.map do |company|
          name_props = {
            on: {
              click: -> { store(:selected_company, @selected_company == company ? nil : company) },
            },
            style: {
              display: 'inline-block',
              padding: '0.2rem 0 0 0',
              cursor: 'pointer',
            },
          }
          name_props[:style][:textDecoration] = 'underline' if @selected_company == company

          company_name = company.name
          owner_name = company.owner.id
          c_size = company_name.size
          o_size = owner_name.size
          if c_size + o_size > 35
            if o_size < 5
              company_name = company_name[0..29] + '…' if c_size > 33
            else
              company_name = company_name[0..19] + '…' if c_size > 23
              owner_name = owner_name[0..9] + '…' if o_size > 13
            end
          end

          div_props = {}

          children = [h(:a, name_props, "#{company_name} (#{owner_name})")]
          if company == @selected_company
            children << h(:div, { style: { margin: '0.2rem 0 0 0' } }, @selected_company.desc)
            children.concat(render_actions)
            div_props = { style: { marginBottom: '0.5rem' } }
          end

          h(:div, div_props, children)
        end.compact
      end

      def render_actions
        actions = actions_for(@selected_company)

        views = []
        views << h(Exchange) if actions.include?('buy_shares')
        views << h(Map, game: @game) if !@game.round.is_a?(Engine::Round::Operating) &&
          (actions & %w[lay_tile place_token]).any?

        views
      end

      private

      def actions_for(company)
        @game.round.actions_for(company)
      end
    end
  end
end
