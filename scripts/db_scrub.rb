# frozen_string_literal: true

raise "You probably don't want to scrub the prod db" unless ENV['RACK_ENV'] == 'development'

require_relative 'scripts_helper'

def scrub_all_users!
  DB.transaction do
    User.each { |user| scrub_user!(user) }

    scrub_passwords!

    scrub_chat!
  end
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

def scrub_chat!
  chat_actions(auto_actions: false).delete
  chat_actions(auto_actions: true).all.each do |db_action|
    db_action.action['message'] = '[redacted]'
    db_action.save
  end
end

def chat_actions(auto_actions:)
  Action.where(**{
                 Sequel.pg_jsonb_op(:action).get_text('type') => 'message',
                 Sequel.pg_jsonb_op(:action).has_key?('auto_actions') => auto_actions, # rubocop:disable Style/PreferredHashMethods
               })
end
