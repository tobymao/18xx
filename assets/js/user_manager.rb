# frozen_string_literal: true

require 'lib/request'
require 'lib/storage'

module UserManager
  def self.included(base)
    base.needs :user, default: nil, store: true
    base.needs :app_route, default: nil, store: true
  end

  def create_user(params)
    Lib::Request.post('/user', params) do |data|
      login_user(data)
    end
  end

  def refresh_user
    return if @user || !Lib::Storage['auth_token']

    Lib::Request.post('/user/refresh') do |data|
      if data
        store(:user, data, skip: true)
        update # for some reason this causes an infinite loop
      else
        Lib::Storage['auth_token'] = nil
      end
    end
  end

  def login(params)
    Lib::Request.post('/user/login', params) do |data|
      login_user(data)
    end
  end

  def logout
    Lib::Request.post('/user/logout')
    Lib::Storage['auth_token'] = nil
    store(:user, nil, skip: true)
    store(:app_route, '/')
  end

  private

  def login_user(data)
    Lib::Storage['auth_token'] = data['auth_token']
    store(:user, data['user'], skip: true)
    store(:app_route, '/')
  end
end
