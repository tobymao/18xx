# frozen_string_literal: true

require 'view/actionable'
require 'view/company'

module View
  class IssueShares < Snabberb::Component
    include Actionable

    def render
      props = {
        style: {
          display: 'inline-block',
        },
      }
      h(:div, props, 'hello')
    end
  end
end
