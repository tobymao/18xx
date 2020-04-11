# frozen_string_literal: true

class Index < Snabberb::Layout
  def render
    css = <<~CSS
      * { font-family: Arial; }
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
        h(:link, attrs: { rel: 'stylesheet', href: 'https://unpkg.com/purecss@1.0.1/build/pure-min.css' }),
        h(:link, attrs: { rel: 'stylesheet', href: 'https://unpkg.com/purecss@1.0.1/build/grids-responsive-min.css' }),
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
