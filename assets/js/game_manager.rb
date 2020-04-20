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
    @connection.safe_post(url(game)) do |data|
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
    game['user']['id'] == user&.dig(:id)
  end

  def unsubscribe
    @connection.unsubscribe('/games')
  end

  protected

  def url(game, path = '')
    "/game/#{game['id']}#{path}"
  end

  def update_game(game)
    @games += game if @games.none? { |g| g['id'] == game['id'] }
    @games.reject! { |g| g['id'] == game['id'] } if game['deleted']
    @games.map! { |g| g['id'] == game['id'] ? game : g }
    store(:games, @games)
  end
end
