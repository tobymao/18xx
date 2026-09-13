# frozen_string_literal: true

require 'view/game/pass_button'
require 'view/game/program_auto_button'

module View
  module Game
    class Pass < Snabberb::Component
      include Actionable
      needs :actions, default: []

      def render
        children = []
        if @actions.include?('pass')
          children << h(PassButton)
          if active_player?
            children << h(ProgramAutoButton, program_action_class: Engine::Action::ProgramSharePass) if @game.round.show_auto?
            children << h(ProgramAutoButton, program_action_class: Engine::Action::ProgramAuctionPass) if show_auction_auto?
          end
        end
        h(:div, children.compact)
      end

      def active_player?
        @game.active_players_id.include?(@user&.dig('id'))
      end

      def show_auction_auto?
        @game.round.auction? && @game.available_programmed_actions.include?(Engine::Action::ProgramAuctionPass)
      end
    end
  end
end
