# frozen_string_literal: true

module View
  class Welcome < Snabberb::Component
    needs :app_route, default: nil, store: true

    def render
      h('div#welcome.half', [
        render_notification,
        render_introduction,
        render_buttons,
      ])
    end

    def render_notification
      message = <<~MESSAGE
        <p>1846 is now available for early alpha. It would help most if you played with the intent to find bugs in hot seat mode.
        The private companies have not been implemented yet. 18Chesapeake is now out of beta and in production.
        </p>

        <p>Please file issues <a href='https://github.com/tobymao/18xx/issues'>here</a>. And if you have any questions, check out the
        <a href='https://docs.google.com/document/d/1nCYnzNMQLrFLZtWdbjfuSx5aIcaOyi27lMYkJxcGayw/edit'>FAQ!</a>
        </p>

        <p>If you're looking to buy these games, please check out
        <a href='https://all-aboardgames.com'>All-Aboard Games</a>,
        <a href='https://www.grandtrunkgames.com'>Grand Trunk Games</a>,
        and <a href='https://www.gmtgames.com/'>GMT Games</a>.
        </p>

        <p>You can support this project on <a href='https://www.patreon.com/18xxgames'>Patreon</a>.
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
        <p>18xx.games is a website where you can play async or real-time 18xx games! Right now only 1889 and 18Chesapeake are implemented
        but I'm planning on doing many more in the future.</p>

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
        h('button.button', create_props, 'CREATE A NEW GAME'),
        h('button.button', tutorial_props, 'TUTORIAL'),
      ])
    end
  end
end
