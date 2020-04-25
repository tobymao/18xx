# frozen_string_literal: true

module View
  class Welcome < Snabberb::Component
    needs :user
    needs :app_route, default: nil, store: true

    def render
      props = {
        style: {
          display: 'inline-block',
          'margin-right': '1rem',
        }
      }

      h('div.half', props, [
        render_header,
        render_notification,
        render_introduction,
        render_buttons,
      ])
    end

    def render_header
      h('div.card_header', [
        "Welcome#{@user ? ' ' + @user['name'] : ''}!"
      ])
    end

    def render_notification
      props = {
        style: {
          'background-color': '#FFEC46',
          'padding': '1em',
          'margin': '1rem 0',
        }
      }

      message = <<~MESSAGE
        Welcome to the open beta! Please join me in the 18xx slack #18xxgames channel.
      MESSAGE

      h(:div, props, [
        h(:span, message),
        h(:a, { attrs: { href: 'https://github.com/tobymao/18xx/issues' } }, 'Please file issues here'),
      ])
    end

    def render_introduction
      message = <<~MESSAGE
        <p>18xx.games is a website where you can play async or real-time 18xx games! Right now only 1889 is implemented
        but I'm planning on doing many more in the future.</p>

        <p>You can play locally with hot seat mode without an account. If you want to play multiplayer, you'll need to create an account.</p>

        <p>If you look at other people's games, you can make moves to play around but it won't affect them and changes won't be saved.
        You can clone games in the tools tab and then play around locally.</p>

        <p>In multiplayer games, you'll also be able to make moves for other players, this is so people can say 'pass me this SR' and you don't
        need to wait. Please use this feature politely! I'm also planning on adding a toggle to disable or enable this in the future. </p>
      MESSAGE

      props = {
        props: { innerHTML: message },
        style: {
          margin: '1rem 0',
        },
      }

      h(:div, props)
    end

    def render_buttons
      props = {
        style: {
          'margin': '1rem 0',
        }
      }

      create_props = {
        on: {
          click: -> { store(:app_route, '/new_game') },
        }
      }

      h(:div, props, [
        h('button.button', create_props, 'CREATE A NEW GAME'),
        # h('button.button', { style: { 'margin-left': '1rem' } }, 'TUTORIAL'),
      ])
    end
  end
end
