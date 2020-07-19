# frozen_string_literal: true

require_relative 'base'
require 'argon2'

class User < Base
  one_to_many :games
  one_to_many :session
  one_to_many :game_users

  RESET_WINDOW = 60 * 15 # 15 minutes

  opts = %w[notifications red_logo bg font bg2 font2 white yellow green brown gray red blue]
  4.times do |n|
    %w[color dash width].each do |prop|
      opts << "r#{n}_#{prop}"
    end
  end
  SETTINGS = opts.freeze

  def update_settings(params)
    SETTINGS.each { |setting| settings[setting] = params[setting] }
  end

  def self.by_email(email)
    self[Sequel.function(:lower, :email) => email.downcase]
  end

  def reset_hashes
    now = Time.now.to_i / RESET_WINDOW
    (0..1).map { |i| Digest::MD5.hexdigest("#{password}#{now + i}") }
  end

  def password=(new_password)
    raise 'Password cannot be empty' if new_password.empty?

    super Argon2::Password.create(new_password)
  end

  def can_reset?
    settings['last_password_reset'].to_i < Time.now.to_i - RESET_WINDOW
  end

  def to_h(for_user: false)
    h = {
      id: id,
      name: name,
    }

    if for_user
      h[:email] = email
      h[:settings] = settings
    end

    h
  end

  def inspect
    "#{self.class.name} - id: #{id} name: #{name}"
  end
end
