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
        Thanks for participating in the beta! I've rewritten the networking code so iPhones should work now!
        Please join me in the 18xx slack #18xxgames channel
      MESSAGE

      h(:div, props, [
        h(:span, message),
        h(:a, { attrs: { href: 'https://github.com/tobymao/18xx/issues' } }, 'Please file issues here'),
      ])
    end

    def render_introduction
      props = {
        margin: '1rem 0'
      }

      message = <<~MESSAGE
        This is a paragraph explaining what 18xx.games is all about, and how to get into a game or start one maybe.
        Also probably something about how you can create a hotseat game without creating an account.
      MESSAGE

      h(:div, props, message)
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
        h('button.button', { style: { 'margin-left': '1rem' } }, 'TUTORIAL'),
      ])
    end
  end
end
