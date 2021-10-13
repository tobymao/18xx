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
        h(:title, '18xx.Games'),
        # rubocop:disable Layout/LineLength
        h(:link, attrs: { rel: 'stylesheet', href: 'https://cdn.jsdelivr.net/npm/normalize.css@8.0.1/normalize.min.css' }),
        h(:link, attrs: { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Lato:wght@300;400;700&display=swap' }),
        h(:link, attrs: { id: 'favicon_svg', rel: 'icon', type: 'image/svg+xml', href: '/images/icon.svg' }),
        h(:link, attrs: { id: 'favicon_32', rel: 'icon', type: 'image/png', sizes: '32x32', href: '/images/favicon-32x32.png' }),
        h(:link, attrs: { id: 'favicon_16', rel: 'icon', type: 'image/png', sizes: '16x16', href: '/images/favicon-16x16.png' }),
        # Alas iOS doesn't seem to support svgs for this, this image must be at top level
        h(:link, attrs: { id: 'favicon_apple', rel: 'apple-touch-icon', href: '/apple-touch-icon.png' }),

        h(:link, attrs: { rel: 'mask-icon', href: '/images/mask.svg', color: '#f0e68c' }),
        h(:link, attrs: { rel: 'manifest', href: '/site.webmanifest' }),
        # Microsoft tiles
        h(:meta, attrs: { rel: 'msapplication-TileColor', content: '#da532c' }),
        h(:meta, attrs: { id: 'theme_color', rel: 'theme-color', name: 'theme-color', content: '#ffffff' }),
        h(:meta, attrs: { id: 'theme_ms', rel: 'msapplication-navbutton-color', name: 'msapplication-navbutton-color', content: '#ffffff' }),
        h(:meta, attrs: { id: 'theme_apple', rel: 'apple-mobile-web-app-status-bar-style', name: 'apple-mobile-web-app-status-bar-style', content: '#ffffff' }),

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
