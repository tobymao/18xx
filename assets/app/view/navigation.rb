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

      props = {
        style: {
          display: 'flex',
          marginBottom: '1rem',
          paddingBottom: '1vmin',
          boxShadow: '0 2px 0 0 gainsboro',
          justifyContent: 'space-between',
        },
      }

      h('div#header', props, [
        h(Logo),
        render_other_links(other_links),
      ])
    end

    def item(name, href)
      props = {
        attrs: {
          href: href,
        },
        style: {
          margin: '0 1rem',
        },
      }
      h(:a, props, name)
    end

    def render_other_links(other_links)
      children = other_links.map do |link|
        link
      end

      nav_props = {
        style: {
          margin: 'auto 0',
        },
      }
      h('div#nav', nav_props, children)
    end
  end
end
