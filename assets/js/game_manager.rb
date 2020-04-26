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
    time = Time.now

    game_data = {
      status: 'active',
      actions: [],
      **opts,
      id: "hs_#{time.to_i}",
      mode: :hotseat,
      user: { id: 0, name: 'You' },
      created_at: time.strftime('%Y-%m-%-d'),
    }

    game_id = game_data[:id]
    Lib::Storage[game_id] = game_data

    store(:game, nil, skip: true)
    store(:game_data, game_data, skip: true)
    store(:app_route, "/hotseat/#{game_id}")
  end

  def get_games(params)
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
      return store(:flash_opts, "Hotseat game #{game_id} not found") unless game_data

      store(:game_data, game_data, skip: true)
      return @app_route.include?(hs_url(game)) ? update : store(:app_route, hs_url(game))
    end

    @connection.safe_get(url(game)) do |data|
      store(:game_data, data, skip: true)
      store(:app_route, url(game))
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

  def unsubscribe
    @connection.unsubscribe('/games')
  end

  protected

  def url(game, path = '')
    "/game/#{game['id']}#{path}"
  end

  def hs_url(game)
    "/hotseat/#{game['id']}"
  end

  def update_game(game)
    @games += [game] if @games.none? { |g| g['id'] == game['id'] }
    @games.reject! { |g| g['id'] == game['id'] } if game['deleted']
    @games.map! { |g| g['id'] == game['id'] ? game : g }
    store(:games, @games.sort_by { |g| g['id'] }.reverse)
  end
end
