# frozen_string_literal: true

raise "You probably don't want to scrub the prod db" unless ENV['RACK_ENV'] == 'development'

require_relative 'scripts_helper'

def scrub_all_users!
  User.each { |user| scrub_user!(user) }

  scrub_passwords!

  Action.where(**{ Sequel.pg_jsonb_op(:action).get_text('type') => 'message' }).delete
end

def scrub_user!(user)
  user.email = "#{user.name.gsub(/\s/, '_')}@example.com"
  user.settings = { 'consent' => true }
  user.save
rescue StandardError
  Game.where(id: user.game_users.map(&:game_id)).delete
  user.destroy
end

def scrub_passwords!
  DB[:users].update(password: Argon2::Password.create('password'))
end
