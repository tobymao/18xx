# frozen_string_literal: true

require 'view/create_game'
require 'view/logo'

module View
  class Navigation < Snabberb::Component
    needs :app_route, default: nil, store: true
    needs :user, default: nil, store: true

    def render
      if @user
        games_links = [item('Your Games', '/?games=personal&status=active')]
        games_links << item('New Games', '/?games=all&status=new')
        other_links = [item("Profile (#{@user['name']})", '/profile')]
      else
        games_links = [item('All Games', '/?games=all&status=new')]
        other_links = [item('Signup', '/signup'), item('Login', '/login')]
      end
      other_links << item('About', '/about')

      props = {
        style: {
          display: 'grid',
          grid: '1fr / auto 1fr',
          marginBottom: '1rem',
          paddingBottom: '1vmin',
          boxShadow: '0 2px 0 0 gainsboro',
        },
      }

      h('div#header', props, [
        h(Logo),
        h(:div, [
          h('nav#games_nav', [
            h('ul.no_margin.no_padding', games_links),
          ]),
          h('nav#main_nav', [
            h('ul.no_margin.no_padding', other_links),
          ]),
        ]),
      ])
    end

    def item(name, anchor)
      h('li.nav', [h(:a, { attrs: { href: anchor } }, name)])
    end
  end
end
