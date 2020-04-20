# frozen_string_literal: true

class Index < Snabberb::Layout
  def render
    css = <<~CSS
      * { font-family: 'Inconsolata', monospace; }

      .card_header {
        font-size: 15px;
        font-weight: bold;
        margin: 1rem 0;
      }

      .back {
        font-size: 15px;
        font-weight: bold;
        margin: 1rem 0;
      }

      .button {
        font-size: 14px;
        border: solid 1px black;
        padding: 0.2rem 1rem;
        cursor: pointer;
        outline-style: none;
      }

      .button:hover {
        background-color: black;
        color: white;
      }

      .half {
        width: 100%;
        display: inline-block;
      }

      @media only screen and (min-width: 800px) {
        .half { width: 47%; }
      }
    CSS

    view_port = {
      name: 'viewport',
      content: 'width=device-width, initial-scale=1, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0',
    }

    h(:html, [
      h(:head, [
        h(:meta, props: { charset: 'utf-8' }),
        h(:meta, props: view_port),
        h(:title, '18xx.games'),
        # rubocop:disable Layout/LineLength
        h(:link, attrs: { rel: 'stylesheet', href: 'https://cdn.jsdelivr.net/npm/normalize.css@8.0.1/normalize.min.css' }),
        h(:link, attrs: { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Inconsolata:wght@400;700&display=swap' }),
        # rubocop:enable Layout/LineLength
        h(:style, props: { innerHTML: css }),
      ]),
      h(:body, [
        @application,
        h(:div, props: { innerHTML: @javascript_include_tags }),
        h(:script, props: { innerHTML: @attach_func }),
      ]),
    ])
  end
end
