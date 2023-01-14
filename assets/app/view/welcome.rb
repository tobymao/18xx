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
        <p>18GB, 18NY and 18USA are now in production.</p>
        <p>Learn how to get <a href='https://github.com/tobymao/18xx/wiki/Notifications'>notifications</a> by email, Slack, Discord, and Telegram.</p>
        <p>Please submit problem reports and make suggestions for improvements on
        <a href='https://github.com/tobymao/18xx/issues'>GitHub</a>. Join the
        <a href='https://join.slack.com/t/18xxgames/shared_invite/zt-8ksy028m-CSZC~G5QtiFv60_jdqqulQ'>18xx Slack</a>.
        to chat about 18xx and the website.
        </p>
        <p>The <a href='https://github.com/tobymao/18xx/wiki'>18xx.games Wiki</a> has rules, maps,
        and other information about all the games, along with an FAQ.</p>

        <p>Support our publishers: #{Lib::Publisher.link_list.join}.</p>
        <p>You can support this project on <a href='https://www.patreon.com/18xxgames'>Patreon</a>.</p>
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
        If you are new to 18xx games then Shikoku 1889, 18Chesapeake, or 18MS are good games to begin with.</p>

        <p>You can play locally with hot seat mode without an account. If you want to play multiplayer, you'll need to create an account.</p>

        <p>If you look at other people's games, you can make moves to play around but it won't affect them and changes won't be saved.
        You can clone games in the tools tab and then play around locally.</p>

        <p>In multiplayer games, you'll also be able to make moves for other players, this is so people can say 'pass me this SR' and you don't
        need to wait. To use this feature in a game, enable "Master Mode" in the Tools tab. Please use it politely!</p>
      MESSAGE

      props = {
        style: {
          marginBottom: '1rem',
        },
        props: {
          innerHTML: message,
        },
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
