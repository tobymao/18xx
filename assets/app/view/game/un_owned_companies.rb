# frozen_string_literal: true

require 'view/game/company'

module View
  module Game
    class UnOwnedCompanies < Snabberb::Component
      needs :companies

      def render
        props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }

        buyable_companies = @companies.flat_map do |company|
          children = [h(Company, company: company)]
          h(:div, props, children)
        end
        h('div.buyable_companies', props, buyable_companies)
      end
    end
  end
end
