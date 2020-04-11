# frozen_string_literal: true

require 'lib/request'
require 'lib/storage'

module GameManager
  def self.included(base)
    base.needs :game_data, default: nil, store: true
    base.needs :games, default: [], store: true
    base.needs :app_route, default: '/', store: true
  end

  def create_game(params)
    Lib::Request.post('/game', params) do |data|
      store(:games, [data] + @games)
    end
  end

  def delete_game(game)
    Lib::Request.post('/game/delete', game) do |data|
      store(:games, @games.reject { |g| g['id'] == data['id'] })
    end
  end

  def join_game(game)
    Lib::Request.post('/game/join', game) do |data|
      update_game(data)
    end
  end

  def leave_game(game)
    Lib::Request.post('/game/leave', game) do |data|
      update_game(data)
    end
  end

  def start_game(game)
    Lib::Request.post('/game/start', game) do |data|
      update_game(data)
    end
  end

  def enter_game(game)
    url = "/game/#{game['id']}"
    Lib::Request.post(url) do |data|
      store(:game_data, data, skip: true)
      store(:app_route, url)
    end
  end

  private

  def update_game(game)
    store(:games, @games.map { |g| g['id'] == game['id'] ? game : g })
  end
end
