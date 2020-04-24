# frozen_string_literal: true

PRODUCTION = ENV['RACK_ENV'] == 'production'

require 'execjs'
require 'message_bus'
require 'opal'
require 'require_all'
require 'roda'
require 'snabberb'
require 'uglifier'

require_relative 'models'
require_relative 'lib/tilt/opal_template'

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

MessageBus.reliable_pub_sub.max_backlog_size = 20

class Api < Roda
  opts[:check_dynamic_arity] = false
  opts[:check_arity] = :warn

  plugin :default_headers,
         'Content-Type' => 'text/html',
         'X-Frame-Options' => 'deny',
         'X-Content-Type-Options' => 'nosniff',
         'Cache-Control' => 'no-store',
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

  plugin :common_logger, Logger.new('log/rack/rack.log')

  plugin :not_found do
    halt(404, 'Page not found')
  end

  plugin :error_handler

  error do |e|
    puts e.backtrace.reverse
    puts "#{e.class}: #{e.message}"
    { error: e.message }
  end

  compress = lambda do |_, type, content|
    type == :js && PRODUCTION ? Uglifier.compile(content, harmony: true) : content
  end

  plugin(
    :assets,
    js: 'app.rb',
    gzip: PRODUCTION,
    concat_only: true,
    postprocessor: compress,
  )

  compile_assets
  APP_JS_PATH = assets_opts[:compiled_js_path]
  APP_JS = "#{APP_JS_PATH}.#{assets_opts[:compiled]['js']}.js"
  Dir[APP_JS_PATH + '*'].sort.each { |file| File.delete(file) unless file.include?(APP_JS) }
  CONTEXT = ExecJS.compile(File.open(APP_JS, 'r:UTF-8', &:read))

  plugin :public
  plugin :hash_routes
  plugin :streaming
  plugin :json
  plugin :json_parser
  plugin :halt

  use MessageBus::Rack::Middleware
  use Rack::Deflater unless PRODUCTION

  PAGE_LIMIT = 100

  STANDARD_ROUTES = %w[
    / about all_tiles hotseat login new_game profile signup
  ].freeze

  Dir['./routes/*'].sort.each { |file| require file }

  hash_routes do
    on 'api' do |hr|
      hr.hash_routes :api

      hr.is 'chat', method: 'post' do
        not_authorized! unless user

        publish(
          '/chat',
          user: user.to_h,
          message: hr.params['message'],
          created_at: Time.now.strftime('%m/%d %H:%M:%S'),
        )
      end
    end
  end

  route do |r|
    unless PRODUCTION
      r.public
      r.assets
    end

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

      render(game_data: game.to_h(include_actions: true))
    end
  end

  def render_with_games
    p = 1
    games = Game
      .eager(:user, :players)
      .reverse_order(:id)
      .limit(PAGE_LIMIT + 1)
      .offset((p - 1) * PAGE_LIMIT)
      .all
    render(games: games.map(&:to_h))
  end

  def render(**needs)
    script = Snabberb.prerender_script(
      'Index',
      'App',
      'app',
      javascript_include_tags: assets(:js),
      app_route: request.path,
      **needs,
    )

    CONTEXT.eval(script)
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

  def publish(channel, **data)
    MessageBus.publish(
      channel,
      data.merge('_client_id': request.params['_client_id'])
    )
    {}
  end
end
