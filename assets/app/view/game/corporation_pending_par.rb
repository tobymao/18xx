# frozen_string_literal: true

require 'view/game/actionable'
require 'view/game/par'
require 'view/game/corporation'

module View
  module Game
    class CorporationPendingPar < Snabberb::Component
      include Actionable
      needs :corporation

      def render
        h(:div, [h(Corporation, corporation: @corporation), h(Par, corporation: @corporation)])
      end
    end
  end
end
