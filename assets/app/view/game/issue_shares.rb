# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/company'

module View
  module Game
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
end
