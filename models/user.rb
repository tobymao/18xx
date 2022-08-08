# frozen_string_literal: true

require_relative 'base'
require_relative '../assets/app/lib/settings'
require 'argon2'
require 'uri'

class User < Base
  one_to_many :games
  one_to_many :session
  one_to_many :game_users

  RESET_WINDOW = 60 * 30 # 30 minutes

  SETTINGS = (Lib::Settings::ROUTE_COLORS.size.times.flat_map do |index|
    %w[color dash width].map do |prop|
      "r#{index}_#{prop}"
    end
  end + %w[
    consent notifications webhook webhook_url webhook_user_id red_logo bg font bg2 font2 your_turn hotseat_game
    white yellow green brown gray red blue purple
    path_timeout route_timeout
  ]).freeze

  def update_settings(params)
    self.name = params['name'] if params['name']
    self.email = params['email'] if params['email']
    params.each do |key, value|
      settings[key] = value if SETTINGS.include?(key)
    end

    settings.delete('webhook_url') if settings['webhook'] != 'custom'
  end

  def self.by_email(email)
    self[Sequel.function(:lower, :email) => email.downcase] || self[Sequel.function(:lower, :name) => email.downcase]
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
      h[:settings] = settings.to_h
    end

    h
  end

  def inspect
    "#{self.class.name} - id: #{id} name: #{name}"
  end

  def validate
    super
    validates_unique(:name, :email, { message: 'is already registered' })
    validates_format(/^.+$/, :name, message: 'may not be empty')
    validates_format(/^[^\s].*$/, :name, message: 'may not start with a whitespace')
    validates_format(/^[^@\s]+@[^@\s]+\.[^@\s]+$/, :email)

    if settings['webhook'] && (
        (settings['webhook_user_id']&.strip || '') == '' ||
        settings['webhook_user_id']&.include?(' ')
      )
      errors.add(:webhook_user_id, 'spaces are not allowed in the user id. look at the wiki for more info')
    end
  end
end
