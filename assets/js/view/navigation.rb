# frozen_string_literal: true

require 'view/create_game'

module View
  class Navigation < Snabberb::Component
    needs :app_route, default: '/', store: true
    needs :user, default: nil, store: true

    def render
      props = {
        style: {
          padding: '1rem 0',
          'box-shadow' => '0 2px 0 0 #f5f5f5',
        }
      }

      children = [
        h('a.pure-menu-heading', { attrs: { href: '/' } }, '18xx.games')
      ]

      if @user
        children << item("Profile (#{@user})", '/profile')
      else
        children << item('Signup', '/signup')
        children << item('Login', '/login')
      end

      h('div.pure-menu.pure-menu-horizontal', props, children)
    end

    def item(name, href)
      h('a.pure-menu-heading', { attrs: { href: href } }, name)
    end
  end
end
