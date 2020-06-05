# frozen_string_literal: true

module View
  class About < Snabberb::Component
    def render
      message = <<~MESSAGE
        <div class="card_header">About 18xx.Games</div>
        <p>18xx.Games is created and maintained by Toby Mao. It is an open source project, and you can find the
        code on <a href='https://github.com/tobymao/18xx/issues' class='default-bg'>GitHub</a>.</p>

        <p><a href='https://boardgamegeek.com/boardgame/23540/1889-history-shikoku-railways' class='default-bg'>1889</a> is used with kind permission from
        Josh Starr at <a href='https://www.grandtrunkgames.com' class='default-bg'>Grand Trunk Games</a>.</p>

        <p><a href='https://boardgamegeek.com/boardgame/253608/18chesapeake' class='default-bg'>18Chesapeake</a> is used with kind permission from
        Scott Petersen at <a href='https://all-aboardgames.com' class='default-bg'>All-Aboard Games</a>.</p>

        <p>This website will always be open-source and free to play. If you'd like support this project, you can become a patron on
        <a href='https://www.patreon.com/18xxgames' class='default-bg'>Patreon</a>.</p>
      MESSAGE

      props = {
        props: {
          innerHTML: message,
        },
      }

      h('div#about', props)
    end
  end
end
