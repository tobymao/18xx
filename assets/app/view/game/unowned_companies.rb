# frozen_string_literal: true

require 'view/game/company'

module View
  module Game
    class UnownedCompanies < Snabberb::Component
      needs :companies

      def render
        props = {
          style: {
            display: 'inline-block',
            verticalAlign: 'top',
          },
        }

        @companies.flat_map do |company|
          children = [h(Company, company: company)]
          h(:div, props, children)
        end
      end
    end
  end
end
