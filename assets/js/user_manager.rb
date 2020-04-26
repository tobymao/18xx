# frozen_string_literal: true

require 'lib/storage'

module UserManager
  def self.included(base)
    base.needs :user, default: nil, store: true
    base.needs :app_route, default: nil, store: true
    base.needs :flash_opts, default: {}, store: true
    base.needs :connection, default: nil, store: true
    base.needs :games, default: [], store: true
  end

  def create_user(params)
    @connection.safe_post('/user', params) do |data|
      login_user(data)
    end
  end

  def refresh_user
    return if @user || !Lib::Storage['auth_token']

    @connection.post('/user/refresh') do |data|
      if data['error']
        invalidate_user
        store(:flash_opts, 'Credentials expired please re-login')
      else
        @connection.authenticate!
        store(:games, data['games'], skip: true)
        store(:user, data['user'], skip: true)
        update # for some reason this causes an infinite loop
      end
    end
  end

  def login(params)
    @connection.safe_post('/user/login', params) do |data|
      login_user(data)
    end
  end

  def logout
    @connection.safe_post('/user/logout')
    invalidate_user
    store(:app_route, '/')
  end

  private

  def login_user(data)
    Lib::Storage['auth_token'] = data['auth_token']
    @connection.authenticate!
    store(:user, data['user'], skip: true)
    store(:games, data['games'], skip: true)
    store(:app_route, '/')
  end

  def invalidate_user
    Lib::Storage['auth_token'] = nil
    @connection.invalidate!
    store(:user, nil, skip: true)
  end
end
