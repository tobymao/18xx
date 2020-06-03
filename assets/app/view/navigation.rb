# frozen_string_literal: true

require 'view/create_game'
require 'view/logo'

module View
  class Navigation < Snabberb::Component
    needs :app_route, default: nil, store: true
    needs :user, default: nil, store: true

    def render
      other_links = [item('About', '/about')]

      if @user
        other_links << item("Profile (#{@user['name']})", '/profile')
      else
        other_links << item('Signup', '/signup')
        other_links << item('Login', '/login')
      end

      h('div#nav', [
        h(Logo),
        render_other_links(other_links),
      ])
    end

    def item(name, href)
      h('a.nav', { attrs: { href: href } }, name)
    end

    def render_other_links(other_links)
      children = other_links.map do |link|
        link
      end

      h(:div, children)
    end
  end
end
