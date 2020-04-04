# frozen_string_literal: true

# require 'execjs'
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

  plugin :streaming
  plugin :json
  plugin :json_parser

  # require_relative 'routes'

  hash_branch 'api' do |_r|
    'test'
  end

  ROOMS = Hash.new { |h, k| h[k] = [] }
  # TODO: this is a hack
  ACTIONS = [] # rubocop:disable Style/MutableConstant

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
      sleep(1)
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

  route do |r|
    r.public
    r.assets
    r.hash_routes('')

    r.root do
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
            <meta name="viewport" content="width=device-width, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0">
            <title>18xx.games</title>
          </head>
          <body>
            <div id="app"></div>
            #{assets(:js)}
          </body>
        </html>
      HTML
    end

    r.on 'game' do
      r.is 'subscribe' do
        room = ROOMS[1]
        q = Queue.new
        room << q

        response['Content-Type'] = 'text/event-stream;charset=UTF-8'
        response['X-Accel-Buffering'] = 'no' # for nginx
        response['Transfer-Encoding'] = 'identity'

        stream(loop: true, callback: -> { on_close(room, q) }) do |out|
          out << "data: #{q.pop}\n\n"
        end
      end

      r.post 'action' do
        action = r.params
        ACTIONS << action
        notify(1, type: 'action', data: action)
        ''
      end

      r.post 'rollback' do
        ACTIONS.pop
        notify(1, type: 'refresh', data: ACTIONS)
        ''
      end

      r.post 'refresh' do
        { type: 'refresh', data: ACTIONS }
      end
    end
  end
end
