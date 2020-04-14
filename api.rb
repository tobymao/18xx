# frozen_string_literal: true

require 'execjs'
require 'opal'
require 'roda'
require 'snabberb'

require_relative 'models'
require_relative 'lib/tilt/opal_template'

Dir['./models/**/*.rb'].sort.each { |file| require file }

class Api < Roda
  opts[:check_dynamic_arity] = false
  opts[:check_arity] = :warn

  plugin :default_headers,
         'Content-Type' => 'text/html',
         # 'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
         'X-Frame-Options' => 'deny',
         # 'X-Content-Type-Options' => 'nosniff',
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

  plugin :not_found do
    @page_title = 'File Not Found'
    ''
  end

  plugin :error_handler

  error do |e|
    puts e.backtrace.reverse
    puts "#{e.class}: #{e.message}"
    { error: e.message }
  end

  plugin :assets, js: 'app.rb'

  compile_assets
  APP_JS_PATH = assets_opts[:compiled_js_path]
  APP_JS = "#{APP_JS_PATH}.#{assets_opts[:compiled]['js']}.js"
  Dir[APP_JS_PATH + '*'].sort.each { |file| File.delete(file) if file != APP_JS }
  CONTEXT = ExecJS.compile(File.open(APP_JS, 'r:UTF-8', &:read))

  plugin :public
  plugin :hash_routes
  plugin :streaming
  plugin :json
  plugin :json_parser
  plugin :halt

  PAGE_LIMIT = 100
  ROOMS = Hash.new { |h, k| h[k] = [] }

  PING_FUNC = lambda do |*|
    ROOMS
      .values
      .flatten
      .select(&:empty?)
      .each { |q| q.push('{"type":"ping"}') }
  end

  Thread.new do
    loop do
      PING_FUNC.call
      sleep(10)
    end
  end

  Thread.new do
    DB.listen(:channel, loop: PING_FUNC) do |_, _, payload|
      notification = JSON.parse(payload)
      message = JSON.dump(notification['message'])
      room = ROOMS[notification['room_id']]
      room.each { |q| q.push(message) }
    end
  end

  def notify(room_id, message)
    notification = {
      'room_id' => room_id,
      'message' => message,
    }

    DB.notify(:channel, payload: JSON.dump(notification))
  end

  def on_close(room, q)
    room.delete(q)
  end

  Dir['./routes/*'].sort.each { |file| require file }

  hash_routes do
    on 'api' do |hr|
      hr.hash_routes :api
    end
  end

  route do |r|
    r.public
    r.assets
    puts "************** #{r.path} *************"

    r.hash_branches

    r.root do
      render_with_games
    end

    r.on %w[/ signup login profile] do
      render_with_games
    end

    r.on 'game', Integer do |id|
      r.halt 404 unless (game = Game[id])
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
end
