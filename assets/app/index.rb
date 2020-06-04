# frozen_string_literal: true

class Index < Snabberb::Layout
  def render
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
        h(:link, attrs: { rel: 'stylesheet', href: '/assets/main.css' }),
      ]),
      h(:body, [
        @application,
        h(:div, props: { innerHTML: @javascript_include_tags }),
        h(:script, props: { innerHTML: @attach_func }),
      ]),
    ])
  end
end
