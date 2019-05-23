# frozen_string_literal: true

require 'roda'
require 'opal'
require 'opal/sprockets'
require 'opal/sprockets/environment'
require 'sprockets'
require 'uglifier'

OPAL_PATH = './public/js/opal.js'
File.write(OPAL_PATH, Opal::Builder.build('./assets/requires.rb')) unless File.file?(OPAL_PATH)

class EighteenWeb < Roda
  plugin :public

  environment = Sprockets::Environment.new
  environment.append_path('lib')
  environment.append_path('assets/js')
  # environment.js_compressor = :uglifier

  route do |r|
    r.public

    r.on 'assets' do
      r.run environment
    end

    <<-HTML
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Eighteen Web</title>
      </head>
      <body>
        <div id="app"></div>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/snabbdom/0.7.3/snabbdom.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/snabbdom/0.7.3/snabbdom-style.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/snabbdom/0.7.3/snabbdom-props.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/snabbdom/0.7.3/snabbdom-eventlisteners.min.js"></script>
        <script src="/js/opal.js"></script>
        #{Opal::Sprockets.javascript_include_tag('application', sprockets: environment, prefix: '/assets', debug: true)}
      </body>
    </html>
    HTML
  end
end
