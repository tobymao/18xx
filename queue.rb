# frozen_string_literal: true

require 'logger'
require 'require_all'
require_relative 'models'
require_rel './models'
require_relative 'lib/assets'
require_relative 'lib/bus'
require_relative 'lib/mail'

PRODUCTION = ENV['RACK_ENV'] == 'production'

LOGGER = Logger.new($stdout)

Bus.configure(DB)

ASSETS = Assets.new(precompiled: PRODUCTION)

MessageBus.subscribe '/turn', -1 do |msg|
  data = msg.data

  users = User.where(id: data['user_ids']).all
  game = Game[data['game_id']]
  minute_ago = Time.now - 60

  connected = Session
    .where(user: users)
    .group_by(:user_id)
    .having { max(updated_at) > minute_ago }
    .select(:user_id)
    .all
    .map(&:user_id)

  users = users.reject do |user|
    email_sent = user.settings['email_sent'] || 0

    connected.include?(user.id) ||
      user.settings['notifications'] == false ||
      email_sent > minute_ago.to_i
  end

  next if users.empty?

  html = ASSETS.html(
    'assets/app/mail/turn.rb',
    game_data: game.to_h(include_actions: true),
    game_url: data['game_url'],
  )

  users.each do |user|
    user.settings['email_sent'] = Time.now.to_i
    user.save
    Mail.send(user, "18xx.games Game: #{game.title} - #{game.id} - #{data['type']}", html)
    LOGGER.info("mail sent for game: #{game.id} to user: #{user.id}")
  end
end

sleep
