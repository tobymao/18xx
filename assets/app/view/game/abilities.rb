# frozen_string_literal: true

require 'lib/truncate'

module View
  module Game
    class Abilities < Snabberb::Component
      needs :game
      needs :user, default: nil
      needs :selected_company, default: nil, store: true
      needs :show_other_abilities, default: false, store: true
      needs :is_operating_round, default: false, store: true

      def render
        companies = @game.companies.select { |company| !company.closed? && actions_for(company).any? }
        return h(:div) if companies.empty? || @game.round.current_entity.company?

        @is_operating_round = @game.round.is_a?(Engine::Round::Operating)
        current, others = companies.partition { |company| @game.current_entity.owner == company.owner.owner }

        props = { style: { margin: '0 1rem 0 0' } }
        props[:style][:display] = 'inline-block' if !@is_operating_round || current.empty?
        children = [
          h(:h3, props, 'Abilities'),
          *render_companies(current),
        ]

        if others.any?
          others.sort! { |company| company.owner.owner.name == @user&.dig(:name) ? 0 : 1 }

          toggle_show = lambda do
            store(:selected_company, nil, skip: true)
            store(:show_other_abilities, !@show_other_abilities)
          end

          props = {
            attrs: { title: "#{@show_other_abilities ? 'Hide' : 'Show'} companies from other players" },
            style: { width: '7.3rem' },
            on: { click: toggle_show },
          }
          children << h('button.button', props, "#{@show_other_abilities ? 'Hide' : 'Show'} Others")
          children.concat(render_companies(others)) if @show_other_abilities
        end

        children << render_company_action if !@is_operating_round && companies.include?(@selected_company)

        h(:div, { style: { marginBottom: '0.5rem' } }, children)
      end

      def render_company_action
        props = {
          style: {
            maxWidth: '80rem',
            margin: '0.3rem 0 0.5rem 0',
          },
        }

        h(:div, props, [h(:div, @selected_company.desc), *render_actions])
      end

      def render_companies(companies)
        companies.flat_map do |company|
          props = {
            attrs: { title: "Use ability of #{company.name}" },
            on: { click: -> { store(:selected_company, @selected_company == company ? nil : company) } },
            style: {
              cursor: 'pointer',
              display: 'inline-block',
              padding: '0.3rem 1rem 0 0',
            },
          }
          props[:style][:textDecoration] = 'underline' if @selected_company == company

          company_name = company.name.truncate(company.owner.id.size < 5 ? 32 : 19)
          owner_name = company.owner.id.truncate(15)

          [h(:a, props, "#{company_name} (#{owner_name})"),
           @is_operating_round && company == @selected_company ? render_company_action : '']
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
