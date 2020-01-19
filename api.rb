# frozen_string_literal: true

require 'execjs'
require 'opal'
require 'roda'
require 'snabberb'

require_relative 'models'
require_relative 'lib/tilt/opal_template'

class Api < Roda
  opts[:check_dynamic_arity] = false
  opts[:check_arity] = :warn

  plugin :default_headers,
         'Content-Type' => 'text/html',
         # 'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
         'X-Frame-Options' => 'deny',
         # 'X-Content-Type-Options' => 'nosniff',
         'X-XSS-Protection' => '1; mode=block'

  plugin :content_security_policy do |csp|
    csp.default_src :none
    csp.style_src :self
    csp.form_action :self
    csp.script_src :self
    csp.connect_src :self
    csp.base_uri :none
    csp.frame_ancestors :none
  end

  plugin :public
  plugin :hash_routes

  logger = if ENV['RACK_ENV'] == 'test'
             Class.new { def write(_) end }.new
           else
             $stderr
           end
  plugin :common_logger, logger

  plugin :not_found do
    @page_title = 'File Not Found'
    ''
  end

  if ENV['RACK_ENV'] == 'development'
    plugin :exception_page
    class RodaRequest
      def assets
        exception_page_assets
        super
      end
    end
  end

  plugin :error_handler do |e|
    $stderr.print "#{e.class}: #{e.message}\n"
    warn e.backtrace
    next exception_page(e, assets: true) if ENV['RACK_ENV'] == 'development'

    @page_title = 'Internal Server Error'
    ''
  end

  plugin :sessions,
    key: '_app.session', # rubocop:disable Layout/ArgumentAlignment
    # cookie_options: {secure: ENV['RACK_ENV'] != 'test'}, # Uncomment if only allowing https:// access
    secret: ENV.send((ENV['RACK_ENV'] == 'development' ? :[] : :delete), 'APP_SESSION_SECRET')

  plugin :assets, js: 'app.rb'
  # compile_assets
  # context = ExecJS.compile(File.read("#{assets_opts[:compiled_js_path]}.#{assets_opts[:compiled]['js']}.js"))

  # require_relative 'routes'

  hash_branch 'api' do |_r|
    'test'
  end

  route do |r|
    r.public
    r.assets
    r.hash_routes('')

    r.root do
      # context.eval(
      #  Snabberb.prerender_script(
      #    'Index',
      #    'App',
      #    'app',
      #    javascript_include_tags: assets(:js),
      #  )
      # )
      <<~HTML
        <html>
          <head>
            <meta charset="utf-8">
            <title>Snabberb Demo</title>
          </head>
          <body>
            <div id="app"></div>
            #{assets(:js)}
          </body>
        </html>
      HTML
    end
  end
end
