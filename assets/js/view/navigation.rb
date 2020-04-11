# frozen_string_literal: true

require 'view/create_game'

module View
  class Navigation < Snabberb::Component
    needs :app_route, default: '/', store: true
    needs :user, default: nil, store: true

    def render
      props = {
        style: {
          'box-shadow' => '0 2px 0 0 #f5f5f5',
        }
      }

      other_links = []

      if @user
        other_links << item("Profile (#{@user['name']})", '/profile')
      else
        other_links << item('Signup', '/signup')
        other_links << item('Login', '/login')
      end

      h('div.pure-menu.pure-menu-horizontal.pure-u-1', props, [
        h('a.pure-menu-link.pure-menu-heading', { attrs: { href: '/' } }, '18xx.games'),
        render_other_links(other_links),
      ])
    end

    def item(name, href)
      h('a.pure-menu-link', { attrs: { href: href } }, name)
    end

    def render_other_links(other_links)
      children = other_links.map do |link|
        h('li.pure-menu-item', [link])
      end

      props = {
        style: {
          float: :right,
        },
      }

      h('ul.pure-menu-list', props, children)
    end
  end
end
