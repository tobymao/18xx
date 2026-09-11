# frozen_string_literal: true

require 'view/game/pass_button'
require 'view/game/pass_auto_button'
require 'view/game/auction_auto_button'

module View
  module Game
    class Pass < Snabberb::Component
      include Actionable
      needs :actions, default: []

      def render
        children = []
        if @actions.include?('pass')
          children << h(PassButton)
          children << h(PassAutoButton) if @game.round.show_auto? && @game.active_players_id.include?(@user&.dig('id'))
          children << h(AuctionAutoButton) if show_auction_auto?
        end
        h(:div, children.compact)
      end

      def show_auction_auto?
        @game.round.auction? &&
          @game.available_programmed_actions.include?(Engine::Action::ProgramAuctionPass) &&
          @game.active_players_id.include?(@user&.dig('id'))
      end
    end
  end
end
