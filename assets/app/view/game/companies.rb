# frozen_string_literal: true

require 'view/game/company'

module View
  module Game
    class Companies < Snabberb::Component
      needs :game
      needs :user, default: nil

      def render
        children = @game
          .companies
          .select(&:owner)
          .group_by(&:owner)
          .sort_by { |owner, _| owner.name == @user&.dig(:name) ? '' : owner.name }
          .map { |owner, companies| render_companies(owner, companies) }

        h(:div, children)
      end

      def render_companies(owner, companies)
        h(:div, { style: { 'margin-bottom': '0.5rem' } }, [
          h(:div, { style: { 'border-bottom': '1px solid gainsboro' } }, owner.name),
          *companies.map { |c| h(Company, company: c) },
        ])
      end
    end
  end
end
