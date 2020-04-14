# frozen_string_literal: true

require 'view/company'

module View
  class Companies < Snabberb::Component
    needs :game, store: true
    needs :user, default: nil, store: true

    def render
      children = @game
        .companies
        .select { |company| company.owner && company.open? }
        .group_by(&:owner)
        .sort_by { |owner, _| owner.name == @user&.dig(:name) ? '' : owner.name }
        .map { |owner, companies| render_companies(owner, companies) }

      h(:div, children)
    end

    def render_companies(owner, companies)
      h(:div, [
        h(:div, { style: { 'border-bottom': '1px solid gainsboro' } }, owner.name),
        *companies.map { |c| h(Company, company: c) },
      ])
    end
  end
end
