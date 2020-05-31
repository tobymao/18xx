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
        },
      }

      other_links = [item('About', '/about')]

      if @user
        other_links << item("Profile (#{@user['name']})", '/profile')
      else
        other_links << item('Signup', '/signup')
        other_links << item('Login', '/login')
      end

      logo_props = {
        attrs: {
          src: '/images/logo.svg',
        },
        style: {
          position: 'absolute',
          top: '16px',
          width: '80px',
        },
      }

      h(:div, props, [
        h(:a, { attrs: { href: '/' } }, [
          h(:img, logo_props),
        ]),
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
          'text-align': 'right',
        },
      }

      h(:div, props, children)
    end
  end
end
