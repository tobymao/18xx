# frozen_string_literal: true

module View
  class About < Snabberb::Component
    def render
      message = <<~MESSAGE
        <div class="card_header">About 18xx.Games</div>
        <p>18xx.Games is created and maintained by Toby Mao. It is an open source project, and you can find the
        code on <a href='https://github.com/tobymao/18xx/issues'>GitHub</a>.</p>

        <p><a href='https://boardgamegeek.com/boardgame/23540/1889-history-shikoku-railways'>1889</a> is used with permission from
        Josh Starr at <a href='https://www.grandtrunkgames.com'>Grand Trunk Games</a>.</p>

        <p><a href='https://boardgamegeek.com/boardgame/253608/18chesapeake'>18Chesapeake</a> is used with permission from
        Scott Petersen at <a href='https://all-aboardgames.com'>All-Aboard Games</a>.</p>

        <p><a href='https://boardgamegeek.com/boardgame/17405/1846-race-midwest'>1846</a> is used with permission from
        <a href='https://sites.google.com/site/ptlehmann/gaming'>Tom Lehmann</a>.</p>

        <p><a href='https://boardgamegeek.com/boardgameexpansion/173574/1836jr'>1836jr</a> is used with permission from
        David Hecht</p>

        <p>This website will always be open-source and free to play. If you'd like support this project, you can become a patron on
        <a href='https://www.patreon.com/18xxgames'>Patreon</a>.</p>
      MESSAGE

      props = {
        props: { innerHTML: message },
        style: { margin: '2rem 1rem' },
      }

      h('div#about', props)
    end
  end
end
