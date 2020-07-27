# frozen_string_literal: true

module View
  module Game
    class Abilities < Snabberb::Component
      needs :game
      needs :user, default: nil
      needs :selected_company, default: nil, store: true
      needs :show_other_abilities, default: false, store: true

      def render
        companies = @game.companies.select { |company| !company.closed? && actions_for(company).any? }
        return h(:div) if companies.empty? || @game.round.current_entity.company?

        current, others = companies.partition { |company| @game.current_entity.owner == company.owner.owner }

        props = { style: { marginRight: '1rem' } }
        children = [
          h('h3.inline', props, 'Abilities:'),
          *render_companies(current),
        ]

        if others.any?
          others.sort! { |company| company.owner.owner.name == @user&.dig(:name) ? 0 : 1 }

          toggle_show = lambda do
            store(:selected_company, nil, skip: true)
            store(:show_other_abilities, !@show_other_abilities)
          end

          props = {
            style: { margin: '0.5rem 0.5rem 0 0' },
            on: { click: toggle_show },
          }
          children << h('button.button', props, @show_other_abilities ? 'Hide' : 'Show Others')
          children.concat(render_companies(others)) if @show_other_abilities
        end

        if companies.include?(@selected_company)
          props = {
            style: {
              maxWidth: '80rem',
              margin: '0.3rem 0 0.5rem 0',
            },
          }
          children << h(:div, props, @selected_company.desc)
          children.concat(render_actions)
        end

        props = { style: { marginBottom: '0.5rem' } }
        h(:div, props, children)
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
              padding: '0.5rem 1rem 0 0',
            },
          }
          props[:style][:textDecoration] = 'underline' if @selected_company == company

          company_name = company.name
          owner_name = company.owner.id
          c_size = company_name.size
          o_size = owner_name.size
          limit = 36
          if c_size + o_size > limit
            if o_size < 5
              company_name = company_name[0..(limit - 7)] + '…' if c_size > (limit - 3)
            else
              company_name = company_name[0..(limit - 17)] + '…' if c_size > (limit - 13)
              owner_name = owner_name[0..9] + '…' if o_size > 13
            end
          end

          h(:a, props, "#{company_name} (#{owner_name})")
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
