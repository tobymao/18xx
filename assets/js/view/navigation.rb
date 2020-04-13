# frozen_string_literal: true

require 'view/create_game'

module View
  class Navigation < Snabberb::Component
    needs :app_route, default: nil, store: true
    needs :user, default: nil, store: true

    def render
      props = {
        style: {
          padding: '1rem',
          'box-shadow': '0 2px 0 0 gainsboro',
        }
      }

      other_links = []

      if @user
        other_links << item("Profile (#{@user['name']})", '/profile')
      else
        other_links << item('Signup', '/signup')
        other_links << item('Login', '/login')
      end

      h(:div, props, [
        h(:a, { attrs: { href: '/' } }, '18xx.games'),
        render_other_links(other_links),
      ])
    end

    def item(name, href)
      props = {
        attrs: { href: href },
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

      props = {
        style: {
          float: :right,
        },
      }

      h(:div, props, children)
    end
  end
end
