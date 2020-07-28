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
        return h(:div) if companies.empty? || @game.round.current_entity.company?

        current, others = companies.partition { |company| @game.current_entity.player == company.player }

        children = [
          h('div.inline.margined.bold', 'Abilities:'),
          *render_companies(current),
        ]

        if others.any?
          others.sort! { |company| company.owner.owner.name == @user&.dig(:name) ? 0 : 1 }

          toggle_show = lambda do
            store(:selected_company, nil, skip: true)
            store(:show_other_abilities, !@show_other_abilities)
          end

          children << h('button.button', { on: { click: toggle_show } }, @show_other_abilities ? 'Hide' : 'Show')
          children.concat(render_companies(others)) if @show_other_abilities
        end

        if companies.include?(@selected_company)
          children << h(:div, { style: { margin: '0.5rem 0' } }, @selected_company.desc)
          children.concat(render_actions)
        end

        h(:div, children)
      end

      def render_companies(companies)
        companies.map do |company|
          props = {
            on: {
              click: -> { store(:selected_company, @selected_company == company ? nil : company) },
            },
            style: {
              cursor: 'pointer',
              display: 'inline-block',
              padding: '0.5rem',
            },
          }
          props[:style][:textDecoration] = 'underline' if @selected_company == company

          company_name = company.name
          company_name = company_name[0..15] + '...' if company_name.size > 16

          owner_name = company.owner.id
          owner_name = owner_name[0..10] + '...' if owner_name.size > 11

          h(:div, props, "#{company_name} (#{owner_name})")
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
