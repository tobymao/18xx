# frozen_string_literal: true

require 'api'
require 'lib/request'
require 'lib/storage'

module UserManager
  include Api

  def self.included(base)
    base.needs :user, default: nil, store: true
    base.needs :app_route, default: nil, store: true
    base.needs :flash_opts, default: {}, store: true
  end

  def create_user(params)
    safe_post('/user', params) do |data|
      login_user(data)
    end
  end

  def refresh_user
    return if @user || !Lib::Storage['auth_token']

    Lib::Request.post('/user/refresh') do |data|
      if data['error']
        Lib::Storage['auth_token'] = nil
      else
        store(:user, data, skip: true)
        update # for some reason this causes an infinite loop
      end
    end
  end

  def login(params)
    safe_post('/user/login', params) do |data|
      login_user(data)
    end
  end

  def logout
    safe_post('/user/logout')
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
