# frozen_string_literal: true

require 'lib/storage'

module GameManager
  def self.included(base)
    base.needs :game, default: nil, store: true
    base.needs :game_data, default: nil, store: true
    base.needs :games, default: [], store: true
    base.needs :app_route, default: nil, store: true
    base.needs :connection, default: nil, store: true
    base.needs :flash_opts, default: {}, store: true
  end

  def create_hotseat(**opts)
    salt = Array.new(8) { [*'a'..'z'].sample }.join
    id = opts[:id].to_s.scan(/\d+/).first.to_i

    game_data = {
      status: 'active',
      actions: [],
      **opts,
      id: "hs_#{salt}_#{id}",
      mode: :hotseat,
      user: { id: 0, name: 'You' },
      created_at: Time.now.strftime('%Y-%m-%d'),
    }

    game_id = game_data[:id]
    Lib::Storage[game_id] = game_data

    store(:game, nil, skip: true)
    store(:game_data, game_data, skip: true)
    store(:app_route, "/hotseat/#{game_id}")
  end

  def enter_tutorial
    @connection.safe_get('/assets/tutorial.json', '') do |data|
      store(:game_data, data, skip: false)
    end
  end

  def get_games(params = nil)
    params ||= `window.location.search`

    @connection.safe_get("/game#{params}") do |data|
      store(:games, data[:games])
    end
  end

  def create_game(params)
    @connection.safe_post('/game', params) do |data|
      store(:games, [data] + @games)
      store(:app_route, '/', skip: true)
    end
  end

  def delete_game(game)
    if game[:mode] == :hotseat
      Lib::Storage.delete(game[:id])
      return update
    end

    @connection.safe_post(url(game, '/delete'), game) do |data|
      update_game(data)
    end
  end

  def join_game(game)
    @connection.safe_post(url(game, '/join')) do |data|
      update_game(data)
    end
  end

  def leave_game(game)
    @connection.safe_post(url(game, '/leave')) do |data|
      update_game(data)
    end
  end

  def start_game(game)
    @connection.safe_post(url(game, '/start')) do |data|
      update_game(data)
    end
  end

  def enter_game(game)
    store(:game, nil, skip: true)
    if game[:mode] == :hotseat
      game_id = game[:id]
      game_data = Lib::Storage[game_id]

      unless game_data
        store(:flash_opts, "Hotseat game #{game_id} not found", skip: true)
        return store(:app_route, '/')
      end

      if game[:pin]
        game_data[:settings] ||= {}
        game_data[:settings][:pin] = game[:pin]
        Lib::Storage[game_id] = game_data
      end

      store(:game_data, game_data.merge(loaded: true), skip: true)
      store(:app_route, hs_url(game, game_data)) unless @app_route.include?(hs_url(game, game_data))
      return
    end

    game_url = url(game)
    store(:game_data, game.merge(loading: true), skip: true)
    store(:app_route, game_url + `window.location.search`)

    @connection.safe_get(game_url) do |data|
      next `window.location = #{game_url}` if data.dig('settings', 'pin')

      `window.history.replaceState(#{data.to_n}, #{@app_route}, #{@app_route})`
      store(:game_data, data, skip: false)
    end
  end

  def kick(game, player)
    @connection.safe_post(url(game, '/kick'), player) do |data|
      update_game(data)
    end
  end

  def user_in_game?(user, game)
    game['players'].map { |p| p['id'] }.include?(user&.dig('id'))
  end

  def user_owns_game?(user, game)
    game[:mode] == :hotseat || game[:user][:id] == user&.dig(:id)
  end

  def user_is_acting?(user, game)
    game['status'] == 'active' && game['acting'].include?(user&.dig('id'))
  end

  def url(game, path = '')
    "/game/#{game['id']}#{path}"
  end

  protected

  def hs_url(game, game_data)
    pin = game_data&.dig('settings', 'pin')

    if pin
      "/hotseat/#{game['id']}?pin=#{pin}"
    else
      "/hotseat/#{game['id']}"
    end
  end

  def update_game(game)
    @games += [game] if @games.none? { |g| g['id'] == game['id'] }
    @games.reject! { |g| g['id'] == game['id'] } if game['deleted']
    @games.map! { |g| g['id'] == game['id'] ? game : g }
    store(:game, game, skip: true) if @game.&['id'] == game['id']
    store(:games, @games.sort_by { |g| g['id'] }.reverse)
  end
end
