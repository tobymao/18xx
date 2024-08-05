# frozen_string_literal: true

PRODUCTION = ENV['RACK_ENV'] == 'production'

require 'opal'
require 'require_all'
require 'roda'
require 'snabberb'
require 'json'

require_relative 'models'
require_rel './lib'
require_rel './models'
require_relative 'lib/engine/test_tiles'

class Api < Roda
  opts[:check_dynamic_arity] = false
  opts[:check_arity] = :warn

  plugin :default_headers,
         'Content-Type' => 'text/html',
         'X-Frame-Options' => 'deny',
         'X-Content-Type-Options' => 'nosniff',
         'cache-control' => 'no-cache, max-age=0, must-revalidate, no-store',
         'X-XSS-Protection' => '1; mode=block'

  plugin :content_security_policy do |csp|
    csp.default_src :self
    csp.style_src :self, :unsafe_inline, 'fonts.googleapis.com', 'cdn.jsdelivr.net'
    csp.font_src :self, 'fonts.gstatic.com'
    csp.form_action :self
    csp.script_src :self, :unsafe_inline, 'cdn.jsdelivr.net'
    csp.connect_src :self
    csp.base_uri :none
    csp.frame_ancestors :none
  end

  API_LOGGER = Logger.new($stdout)

  plugin :common_logger, API_LOGGER

  plugin :not_found do
    halt(404, 'Page not found')
  end

  plugin :error_handler

  error do |e|
    API_LOGGER.error e.backtrace
    API_LOGGER.error e.message
    { error: e.message }
  end

  plugin :public
  plugin :hash_routes
  plugin :streaming
  plugin :json
  plugin :json_parser
  plugin :halt
  plugin :cookies
  plugin :new_relic if PRODUCTION

  unless PRODUCTION
    plugin :assets, {
      path: 'public/assets',
      js_dir: nil,
      js_route: nil,

      # g_*.js files for each game
      js: Dir['lib/engine/game/*/game.rb'].map { |dir| dir.split('/')[-2] + '.js' },

      # compile on demand
      postprocessor: lambda do |file, _type, _content|
                       ASSETS.combine([file.split(%r{[./]})[-2]])
                       File.read(file)
                     end,
    }
  end

  ASSETS = Assets.new(precompiled: PRODUCTION, source_maps: !PRODUCTION)

  Bus.configure

  use MessageBus::Rack::Middleware
  use Rack::Deflater unless PRODUCTION

  STANDARD_ROUTES = %w[
    / about hotseat login new_game signup tutorial forgot reset
  ].freeze

  ROUTES_WITH_GAME_TITLES = %w[
     map market fixture
  ].freeze

  Dir['./routes/*'].each { |file| require file }

  hash_routes do
    on 'api' do |hr|
      hr.hash_routes :api

      hr.is 'chat', method: 'post' do
        not_authorized! unless user

        publish(
          '/chat',
          100,
          user: user.to_h,
          message: hr.params['message'],
          created_at: Time.now.to_i,
        )
      end
    end
  end

  route do |r|
    unless PRODUCTION
      r.assets
      r.public
    end

    r.hash_branches

    r.root do
      render_with_games
    end

    r.on STANDARD_ROUTES do
      render_with_games
    end

    r.on ROUTES_WITH_GAME_TITLES do
      render(titles: request.path.split('/')[2].split('+'))
    end

    r.on 'profile' do
      r.get Integer do |id|
        halt(404, 'User does not exist') unless (profile = User[id])

        needs = { profile: profile&.to_h(for_user: false) }

        if profile.settings['show_stats']
          begin
            needs[:profile]['stats'] = JSON.parse(Bus[Bus::USER_STATS % id])
          rescue StandardError => e
            API_LOGGER.error "Unable to get stats for #{id}: #{e}"
          end
        end

        render(
          games: Game.profile_games(profile),
          **needs,
        )
      end
    end

    r.on 'tiles' do
      parts = request.path.split('/')

      titles =
        if parts.size == 4
          parts[2].split(/[+ ]/)
        elsif parts[2] == 'test'
          Engine::TestTiles::TEST_TILES.keys.compact
        else
          []
        end

      render(titles: titles)
    end

    r.on 'game', Integer do |id|
      halt(404, 'Game not found') unless (game = Game[id])

      pin = game.settings['pin']
      render(titles: [game.title], pin: pin,
             game_data: pin ? game.to_h(include_actions: true, logged_in_user_id: user&.id) : game.to_h)
    end

    r.on 'issues', String do |str|
      label =
        case str
        when 'alpha', 'beta', 'production'
          Engine.issues_labels(str.to_sym)
        when 'prealpha'
          '"new games"'
        else
          str
        end

      r.redirect "https://github.com/tobymao/18xx/issues?q=is%3Aissue+is%3Aopen+label%3A#{label}"
    end
  end

  def render_with_games
    render(
      title: request.params['title'],
      pin: request.params['pin'],
      games: Game.home_games(user, **request.params),
    )
  end

  def render(titles: nil, **needs)
    needs[:user] = user&.to_h(for_user: true)

    return render_pin(**needs) if needs[:pin]

    static(
      js_tags: ASSETS.js_tags(titles || []),
      **needs,
    )
  end

  def render_pin(**needs)
    pin = needs[:pin]

    static(
      desc: " (Pin #{pin})",
      js_tags: "<script type='text/javascript' src='#{Assets::PIN_DIR}#{pin}.js'></script>",
      **needs,
    )
  end

  def static(desc: '', js_tags: '', **needs)
    args = Snabberb.wrap(
      app_route: request.path,
      production: PRODUCTION,
      **needs,
    )

    <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
           <meta charset=\"utf-8\">
           <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0\">
           <title>18xx.Games#{desc}</title>
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
          <script>Opal.App.$attach('app', #{args})</script>
        </body>
      </html>
    HTML
  end

  def session
    return unless (token = request.cookies['auth_token'])

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
      data.merge(_client_id: request.params['_client_id']),
      max_backlog_size: limit,
    )
    {}
  end

  MessageBus.user_id_lookup do |env|
    next unless (token = Rack::Request.new(env).cookies['auth_token'])
    next unless (id = Session.first(token: token)&.user_id)

    Bus[Bus::USER_TS % id] = Time.now.to_i

    nil
  end
end
