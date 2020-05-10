# frozen_string_literal: true

module View
  class About < Snabberb::Component
    def render
      message = <<~MESSAGE
        <p>18xx.games is created and maintained by Toby Mao. It is an open source project, and you can find the
        code on <a href='https://github.com/tobymao/18xx/issues'>Github</a>.</p>

        <p><a href='https://boardgamegeek.com/boardgame/23540/1889-history-shikoku-railways'>1889</a> is used with kind permission from
        Josh Starr at Grand Trunk Games.</p>

        <p>This website will always be open-source and free to play. If you'd like support this project, you can become a patron on
        <a href='https://www.patreon.com/18xxgames'>Patreon</a>.</p>
      MESSAGE

      props = {
        style: {
          'padding': '1em',
          'margin': '1rem 0',
        },
        props: {
          innerHTML: message,
        }
      }

      h(:div, props)
    end
  end
end
