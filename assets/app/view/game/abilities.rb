# frozen_string_literal: true

require 'lib/truncate'

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
          h('h3.inline', { style: { marginRight: '0.5rem' } }, 'Abilities:'),
          *render_companies(current),
        ]

        if others.any?
          others.sort! { |company| company.owner.owner.name == @user&.dig(:name) ? 0 : 1 }

          toggle_show = lambda do
            store(:selected_company, nil, skip: true)
            store(:show_other_abilities, !@show_other_abilities)
          end

          props = {
            attrs: { title: "#{@show_other_abilities ? 'Hide' : 'Show'} companies of other players" },
            style: { width: '7.3rem', margin: '0 0 0 0.5rem' },
            on: { click: toggle_show },
          }
          children << h(:button, props, "#{@show_other_abilities ? 'Hide' : 'Show'} Others")
          children.concat(render_companies(others)) if @show_other_abilities
        end

        if companies.include?(@selected_company)
          children << h(:div, { style: { margin: '0.5rem 0 0 0', maxWidth: '60rem' } }, @selected_company.desc)
          children.concat(render_actions)
        end

        h(:div, { style: { marginBottom: '0.5rem' } }, children)
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
              padding: '0 0.5rem',
            },
          }
          props[:style][:textDecoration] = 'underline' if @selected_company == company

          company_name = company.name.truncate(company.owner.id.size < 5 ? 32 : 19)
          owner_name = company.owner.id.truncate

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
