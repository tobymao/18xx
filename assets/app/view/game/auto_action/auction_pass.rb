# frozen_string_literal: true

require 'view/game/auto_action/base'

module View
  module Game
    module AutoAction
      class AuctionPass < Base
        def name
          "Auto pass in Auction Round#{' (Enabled)' if @settings}"
        end

        def description
          'Passes your turn in the initial auction each time it comes back around, and stops as '\
            'soon as someone outbids you on a company you are winning. Enable it with the '\
            '"Auto pass" button next to Pass during the auction.'
        end

        def render
          return [] unless @game.round.auction?

          children = [h(:h3, name), h(:p, description)]
          children << h(:div, [render_disable]) if @settings
          children
        end
      end
    end
  end
end
