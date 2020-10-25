# frozen_string_literal: true

PRODUCTION = ENV['RACK_ENV'] == 'production'

require 'opal'
require 'require_all'
require 'roda'
require 'snabberb'

require_relative 'models'
require_relative 'lib/assets'
require_relative 'lib/bus'
require_relative 'lib/mail'

require_rel './models'

class Api < Roda
  opts[:check_dynamic_arity] = false
  opts[:check_arity] = :warn

  plugin :default_headers,
         'Content-Type' => 'text/html',
         'X-Frame-Options' => 'deny',
         'X-Content-Type-Options' => 'nosniff',
         'Cache-Control' => 'no-cache, max-age=0, must-revalidate, no-store',
         'X-XSS-Protection' => '1; mode=block'

  plugin :content_security_policy do |csp|
    csp.default_src :self
    csp.style_src :self
    csp.form_action :self
    csp.script_src :self
    csp.connect_src :self
    csp.base_uri :none
    csp.frame_ancestors :none
  end

  LOGGER = Logger.new($stdout)

  plugin :common_logger, LOGGER

  plugin :not_found do
    halt(404, 'Page not found')
  end

  plugin :error_handler

  error do |e|
    puts e.backtrace.reverse
    puts "#{e.class}: #{e.message}"
    LOGGER.error e.backtrace
    { error: e.message }
  end

  plugin :public
  plugin :hash_routes
  plugin :streaming
  plugin :json
  plugin :json_parser
  plugin :halt

  ASSETS = Assets.new(precompiled: PRODUCTION)

  Bus.configure(DB)

  use MessageBus::Rack::Middleware
  use Rack::Deflater unless PRODUCTION

  STANDARD_ROUTES = %w[
    / about hotseat login map new_game profile signup tiles tutorial forgot reset
  ].freeze

  Dir['./routes/*'].sort.each { |file| require file }

  hash_routes do
    on 'api' do |hr|
      hr.hash_routes :api

      hr.is 'chat', method: 'post' do
        not_authorized! unless user

        publish(
          '/chat',
          50,
          user: user.to_h,
          message: hr.params['message'],
          created_at: Time.now.to_i,
        )
      end
    end
  end

  route do |r|
    r.public unless PRODUCTION

    r.hash_branches

    r.root do
      render_with_games
    end

    r.on STANDARD_ROUTES do
      render_with_games
    end

    r.on 'game', Integer do |id|
      halt(404, 'Game not found') unless (game = Game[id])

      pin = game.settings['pin']
      render(pin: pin, game_data: pin ? game.to_h(include_actions: true) : game.to_h)
    end
  end

  def render_with_games
    render(pin: request.params['pin'], games: Game.home_games(user, **request.params).map(&:to_h))
  end

  def render(**needs)
    return debug(**needs) if request.params['debug'] && !PRODUCTION
    return render_pin(**needs) if needs[:pin]

    script = Snabberb.prerender_script(
      'Index',
      'App',
      'app',
      javascript_include_tags: ASSETS.js_tags,
      app_route: request.path,
      **needs,
    )

    '<!DOCTYPE html>' + ASSETS.context.eval(script, warmup: request.path.split('/')[1].to_s)
  end

  def render_pin(**needs)
    pin = needs[:pin]

    static(
      desc: "Pin #{pin}",
      js_tags: "<script type='text/javascript' src='#{Assets::PIN_DIR}#{pin}.js'></script>",
      attach_func: "Opal.$$.App.$attach('app', #{Snabberb.wrap(app_route: request.path, **needs)})",
    )
  end

  def debug(**needs)
    needs[:disable_user_errors] = true
    needs = Snabberb.wrap(app_route: request.path, **needs)

    static(
      desc: 'Debug',
      js_tags: ASSETS.js_tags,
      attach_func: "Opal.$$.App.$attach('app', #{needs})",
    )
  end

  def static(desc:, js_tags:, attach_func:)
    <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
           <meta charset=\"utf-8\">
           <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0\">
           <title>18xx.Games (#{desc})</title>
           <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/normalize.css@8.0.1/normalize.min.css\">
           <link rel=\"stylesheet\" href=\"https://fonts.googleapis.com/css2?family=Lato:wght@300;400;700&amp;display=swap\">
           <link id=\"favicon_svg\" rel=\"icon\" type=\"image/svg+xml\" href=\"/images/icon.svg\">
           <link id=\"favicon_32\" rel=\"icon\" type=\"image/png\" sizes=\"32x32\" href=\"/images/favicon-32x32.png\">
           <link id=\"favicon_16\" rel=\"icon\" type=\"image/png\" sizes=\"16x16\" href=\"/images/favicon-16x16.png\">
           <link id=\"favicon_apple\" rel=\"apple-touch-icon\" href=\"/apple-touch-icon.png\">
           <link rel=\"mask-icon\" href=\"/images/mask.svg\" color=\"#f0e68c\">
           <link rel=\"manifest\" href=\"/site.webmanifest\">
           <meta rel=\"msapplication-TileColor\" content=\"#da532c\">
           <meta id=\"theme_color\" rel=\"theme-color\" name=\"theme-color\" content=\"#ffffff\">
           <meta id=\"theme_ms\" rel=\"msapplication-navbutton-color\" name=\"msapplication-navbutton-color\" content=\"#ffffff\">
           <meta id=\"theme_apple\" rel=\"apple-mobile-web-app-status-bar-style\" name=\"apple-mobile-web-app-status-bar-style\" content=\"#ffffff\">
           <link rel=\"stylesheet\" href=\"/assets/main.css\">
        </head>
        <body>
          <div id="app"></div>
          #{js_tags}
          <script>#{attach_func}</script>
        </body>
      </html>
    HTML
  end

  def session
    return unless (token = request.env['HTTP_AUTHORIZATION'])

    @session ||= Session.find(token: token)
  end

  def user
    session&.valid? ? session.user : nil
  end

  def halt(code, message)
    request.halt(code, error: message)
  end

  def not_authorized!
    halt(401, 'You are not authorized to make this request')
  end

  def publish(channel, limit = nil, **data)
    MessageBus.publish(
      channel,
      data.merge('_client_id': request.params['_client_id']),
      max_backlog_size: limit,
    )
    {}
  end

  MessageBus.user_id_lookup do |env|
    next unless (token = env['HTTP_AUTHORIZATION'])

    ip =
      if (addr = env['HTTP_X_FORWARDED_FOR'])
        addr.split(',')[-1].strip
      else
        env['REMOTE_ADDR']
      end
    Session.where(token: token).update(updated_at: Sequel::CURRENT_TIMESTAMP, ip: ip)
    nil
  end
end
