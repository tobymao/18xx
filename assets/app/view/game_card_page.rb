# frozen_string_literal: true

require 'game_manager'
require 'view/game_row'

module View
  class GameCardPage < Snabberb::Component
    include GameManager

    needs :user
    needs :refreshing, default: false, store: true

    def render
      game_refresh

      children = []
      children << h(:h2, 'This game has not started yet') if @game_data['status'] == 'new'

      if @user || @game_data['status'] == 'archived'
        children << h(:div, [h(GameCard, gdata: @game_data, user: @user)])
      else
        children << h(:h3, 'You need to login before joining a game:')
        children << h(View::User, type: :login)
      end

      destroy = lambda do
        `clearTimeout(#{@refreshing})`
        store(:refreshing, nil, skip: true)
      end

      props = {
        key: 'game_card_page',
        hook: {
          destroy: destroy,
        },
      }

      h('div', props, children)
    end

    def game_refresh
      return if @refreshing

      timeout = %x{
        setTimeout(function(){
          self['$get_game'](#{@game_data['id']})
          self['$store']('refreshing', nil, Opal.hash({skip: true}))
        }, 10000)
      }

      store(:refreshing, timeout, skip: true)
    end
  end
end
