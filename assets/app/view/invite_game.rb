# frozen_string_literal: true

require 'game_manager'
require 'view/game_row'

module View
  class InviteGame < Snabberb::Component
    include GameManager

    needs :user
    needs :refreshing, default: nil, store: true

    def render
      children = [h(:h2, {}, 'This game has not started yet')]
      if !@user
        children << h(:h3, {}, 'You need to login before joining a game:')
        children << h(View::User, type: :login)
      else
        children << h(:div, {}, [h(GameCard, gdata: @game, user: @user)])
      end

      children << h(:a, { attrs: { href: '/' } }, 'Return home')

      h('div#invitepage', {}, children)
    end
  end
end
