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

  def edit_user(params)
    @connection.safe_post('/user/edit', params) do |data|
      store(:user, data, skip: false)
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

  def delete_user
    @connection.safe_post('/user/delete')
    invalidate_user
    store(:app_route, '/')
  end

  def forgot(params)
    @connection.safe_post('/user/forgot', params) do |data|
      break unless data['result']

      store(:flash_opts, { message: 'Password reset sent!', color: 'lightgreen' }, skip: true)
      store(:app_route, '/')
    end
  end

  def reset(params)
    @connection.safe_post('/user/reset', params) do |data|
      store(:flash_opts, { message: 'Password reset!', color: 'lightgreen' }, skip: true)
      login_user(data)
    end
  end

  private

  def login_user(data)
    store(:user, data['user'], skip: true)
    store(:games, data['games'], skip: true)
    store(:app_route, '/')
  end

  def invalidate_user
    store(:user, nil, skip: true)
  end
end
