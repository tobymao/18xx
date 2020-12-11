# frozen_string_literal: true

require 'lib/publisher'

module View
  class Welcome < Snabberb::Component
    needs :app_route, default: nil, store: true
    needs :show_intro, default: true

    def render
      children = [render_notification]
      children << render_introduction if @show_intro
      children << render_buttons

      h('div#welcome.half', children)
    end

    def render_notification
      message = <<~MESSAGE
        <p>1817NA now in beta!</p>
        <p>18MEX is now in beta!</p>
        <p>1817 is in production!</p>

        <p>Please file <a href='https://github.com/tobymao/18xx/issues'>issues and ideas</a> on
        <a href='https://github.com/tobymao/18xx/issues'>GitHub</a>.<br>
        If you have any questions, check out the <a href="https://github.com/tobymao/18xx/wiki/FAQ">FAQ</a> and other
        resources in our <a href='https://github.com/tobymao/18xx/wiki'>Wiki!</a>
        </p>

        <p>Support our publishers: #{Lib::Publisher.link_list.join}.</p>
        <p>You can support this project on <a href='https://www.patreon.com/18xxgames'>Patreon</a>.</p>

        <p>Consider joining the
        <a href='https://join.slack.com/t/18xxgames/shared_invite/zt-8ksy028m-CSZC~G5QtiFv60_jdqqulQ'>18xx slack</a>.
        General 18xx.games discussion is in <a href='https://18xxgames.slack.com/archives/CV3R3HPUZ'>#18xxgames</a>,
        development discussion is in <a href='https://18xxgames.slack.com/archives/C012K0CNY5C'>#18xxgamesdev</a>
        (you can ask about bugs there), and general 18xx chat in <a href='https://18xxgames.slack.com/archives/C68J3MK2A'>#general</a>.
        </p>
      MESSAGE

      props = {
        style: {
          background: 'rgb(240, 229, 140)',
          color: 'black',
          marginBottom: '1rem',
        },
        props: {
          innerHTML: message,
        },
      }

      h('div#notification.padded', props)
    end

    def render_introduction
      message = <<~MESSAGE
        <p>18xx.games is a website where you can play async or real-time 18xx games (based on the system originally devised by the brilliant Francis Tresham)!
        <p>Right now, 1817, 1836Jr30, 1846, 1882, 1889, 18AL, 18Chesapeake, 18GA, 18 Los Angeles, 18MEX, 18MS, and 18TN are implemented.</br>
        If you are new to 18xx games then 1889, 18Chesapeake, or 18MS are good games to begin with.</p>

        <p>You can play locally with hot seat mode without an account. If you want to play multiplayer, you'll need to create an account.</p>

        <p>If you look at other people's games, you can make moves to play around but it won't affect them and changes won't be saved.
        You can clone games in the tools tab and then play around locally.</p>

        <p>In multiplayer games, you'll also be able to make moves for other players, this is so people can say 'pass me this SR' and you don't
        need to wait. To use this feature in a game, enable "Master Mode" in the Tools tab. Please use it politely!</p>
      MESSAGE

      props = {
        props: { innerHTML: message },
      }

      h('div#introduction', props)
    end

    def render_buttons
      props = {
        style: {
          margin: '1rem 0',
        },
      }

      create_props = {
        on: {
          click: -> { store(:app_route, '/new_game') },
        },
      }

      tutorial_props = {
        on: {
          click: -> { store(:app_route, '/tutorial?action=1') },
        },
      }

      h('div#buttons', props, [
        h(:button, create_props, 'CREATE A NEW GAME'),
        h(:button, tutorial_props, 'TUTORIAL'),
      ])
    end
  end
end
