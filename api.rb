# frozen_string_literal: true

PRODUCTION = ENV['RACK_ENV'] == 'production'

require 'message_bus'
require 'opal'
require 'require_all'
require 'roda'
require 'snabberb'

require_relative 'models'
require_relative 'lib/assets'
require_relative 'lib/mail'

require_rel './models'

MessageBus.configure(
  backend: :postgres,
  backend_options: {
    host: DB.opts[:host],
    user: DB.opts[:user],
    dbname: DB.opts[:database],
    password: DB.opts[:password],
    port: DB.opts[:port],
  },
  clear_every: 10,
)

MessageBus.reliable_pub_sub.max_backlog_size = 1
MessageBus.reliable_pub_sub.max_global_backlog_size = 100_000
MessageBus.reliable_pub_sub.max_backlog_age = 172_800 # 2 days

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

  LOGGER = Logger.new('log/rack/rack.log')

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
  # TODO: This should scan the directory
  PIN_ASSETS = { 'deadbeef' => Assets.new(precompiled: true, pin: 'deadbeef') }.freeze

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
          created_at: Time.now.strftime('%m/%d %H:%M:%S'),
        )
      end
    end
  end

  route do |r|
    r.public unless PRODUCTION

    puts "************** #{r.path} *************"

    r.hash_branches

    r.root do
      render_with_games
    end

    r.on STANDARD_ROUTES do
      render_with_games
    end

    r.on 'game', Integer do |id|
      halt(404, 'Game not found') unless (game = Game[id])
      halt(400, 'Game has not started yet') if game.status == 'new'

      puts game.settings['pin_version']
      render(pin: game.settings['pin_version'], game_data: game.to_h(include_actions: true))
    end
  end

  def render_with_games
    render(games: Game.home_games(user, **request.params).map(&:to_h))
  end

  def render(pin: nil, **needs)
    return debug(**needs) if request.params['debug'] && !PRODUCTION

    asset = PIN_ASSETS[pin] || ASSETS

    script = Snabberb.prerender_script(
      'Index',
      'App',
      'app',
      javascript_include_tags: asset.js_tags,
      app_route: request.path,
      **needs,
    )

    asset.context.eval(script)
  end

  def debug(**needs)
    needs[:disable_user_errors] = true
    needs = Snabberb.wrap(app_route: request.path, **needs)
    attach_func = "Opal.$$.App.$attach('app', #{needs})"

    <<~HTML
      <html>
        <head>
          <meta charset="utf-8">
          <title>18xx.games</title>
        </head>
        <body>
          <div id="app"></div>
          #{ASSETS.js_tags}
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

    Session.where(token: token).update(updated_at: Sequel::CURRENT_TIMESTAMP)
    nil
  end
end
