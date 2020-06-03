# frozen_string_literal: true

class Index < Snabberb::Layout
  def render
    css = <<~CSS
      * { font-family: 'Inconsolata', monospace; }

      /* prevent hover effects on mobile devices */
      @media(hover: hover) and (pointer: fine) {
        .button-link:hover {
          background: black;
          color: white;
        }
        .button:hover {
          background: black;
          border: rgb(217, 210, 210);
          color: white;
        }
        .button:active, .button-link:active {
          outline: 0;
        }
        .button:focus, .button-link:focus {
          opacity: 0.8;
        }
        a.nav:hover, a.default-bg:hover {
          text-decoration: underline dotted;
          opacity: 0.8;
        }
        #logo a:hover {
          opacity: 0.8;
        }
        a:active {
          outline: 0;
        }
      }

      a.nav, a.default-bg  {
        color: currentColor;
      }
      a.nav {
        margin: 0 1rem;
      }

      #nav {
        box-shadow: 0 2px 0 0 gainsboro;
        display: flex;
        justify-content: space-between;
        line-height: 3rem;
        padding: 0 1rem 0.5rem 1rem;
      }
      #logo a {
        color: currentColor;
        font-weight: bold;
        text-decoration: none;
      }
      #logo__18xx {
        display: inline-block;
        height: 3rem;
        text-align: center;
        width: 2.5rem;
      }
      #logo__18xx.yellow {
        background: url(/images/logo_polygon_yellow.svg) left/2.5rem no-repeat;
        color: black;
      }
      #logo__18xx.red {
        background: url(/images/logo_polygon_red.svg) left/2.5rem no-repeat;
        color: white;
      }

      @media (prefers-color-scheme: dark) {
        body {
          background-color: black;
          color: white;
        }
      }

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

      .button, .button-link {
        font-size: 14px;
        background: whitesmoke;
        color: black;
        border: solid 1px black;
        border-radius: 5px;
        padding: 0.2rem 1rem;
        cursor: pointer;
      }

      .button-link {
        text-decoration: none;
        color: initial;
        background: whitesmoke;
      }

      .half {
        width: 100%;
        display: inline-block;
      }

      .margined {
        margin: 1rem 1rem 1rem 0;
      }

      .margined_half {
        margin: 0.5rem 0.5rem 0.5rem 0;
      }

      @media only screen and (min-width: 900px) {
        .half { width: 49%; }
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
        h(:link, attrs: { rel: 'icon', type: 'image/svg+xml', href: '/images/icon.svg' }),
        h(:link, attrs: { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/images/favicon-32x32.png' }),
        h(:link, attrs: { rel: 'icon', type: 'image/png', sizes: '16x16', href: '/images/favicon-16x16.png' }),
        # Alas iOS doesn't seem to support svgs for this, this image must be at top level
        h(:link, attrs: { rel: 'apple-touch-icon', href: '/apple-touch-icon.png' }),

        h(:link, attrs: { rel: 'mask-icon', href: '/images/mask.svg', color: '#f0e68c' }),
        h(:link, attrs: { rel: 'manifest', href: '/site.webmanifest' }),
        # Microsoft tiles
        h(:meta, attrs: { rel: 'msapplication-TileColor', content: '#da532c' }),
        h(:meta, attrs: { rel: 'theme-color', content: '#ffffff' }),

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
