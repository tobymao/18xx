# frozen_string_literal: true

module GameManager
  def self.included(base)
    base.needs :game_data, default: nil, store: true
    base.needs :games, default: [], store: true
    base.needs :app_route, default: nil, store: true
    base.needs :connection, default: nil, store: true
  end

  def create_game(params)
    @connection.safe_post('/game', params) do |data|
      store(:games, [data] + @games)
      store(:app_route, '/', skip: true)
    end
  end

  def delete_game(game)
    @connection.safe_post('/game/delete', game) do |data|
      store(:games, @games.reject { |g| g['id'] == data['id'] })
    end
  end

  def join_game(game)
    @connection.safe_post('/game/join', game) do |data|
      update_game(data)
    end
  end

  def leave_game(game)
    @connection.safe_post('/game/leave', game) do |data|
      update_game(data)
    end
  end

  def start_game(game)
    @connection.safe_post('/game/start', game) do |data|
      update_game(data)
    end
  end

  def enter_game(game)
    url = "/game/#{game['id']}"
    @connection.safe_post(url) do |data|
      store(:game_data, data, skip: true)
      store(:app_route, url)
    end
  end

  def user_in_game?(user, game)
    game['players'].map { |p| p['id'] }.include?(user&.dig('id'))
  end

  def user_owns_game?(user, game)
    game['user']['id'] == user&.dig(:id)
  end

  private

  def update_game(game)
    store(:games, @games.map { |g| g['id'] == game['id'] ? game : g })
  end
end
