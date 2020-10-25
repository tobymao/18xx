# frozen_string_literal: true

require 'game_manager'
require 'view/game_row'

module View
  class InviteGame < Snabberb::Component
    include GameManager

    needs :user

    def render
      children = [h(:h2, 'This game has not started yet')]
      if @user
        children << h(:div, [h(GameCard, gdata: @game, user: @user)])
      else
        children << h(:h3, 'You need to login before joining a game:')
        children << h(View::User, type: :login)
      end

      h('div#invitepage', {}, children)
    end
  end
end
