# frozen_string_literal: true

require 'logger'
require 'rufus-scheduler'
require 'require_all'
require_relative 'models'
require_rel './models'
require_relative 'lib/assets'
require_relative 'lib/bus'
require_relative 'lib/hooks'
require_relative 'lib/mail'
require_relative 'lib/user_stats'

PRODUCTION = ENV['RACK_ENV'] == 'production'

LOGGER = Logger.new($stdout)

Bus.configure

ASSETS = Assets.new(precompiled: PRODUCTION)

scheduler = Rufus::Scheduler.new

scheduler.cron '00 09 * * *' do
  LOGGER.info('Calculating user stats')
  UserStats.calculate_stats
end

def send_webhook_notification(user, message)
  return if user.settings['notifications'] != 'webhook'
  return if (user.settings['webhook_user_id']&.strip || '') == ''

  begin
    Hooks.send(user, message)
  rescue Exception => e # rubocop:disable Lint/RescueException
    puts e.backtrace
    puts e
  end
end

MessageBus.subscribe '/test_notification' do |msg|
  user_id = msg.data
  user = User[user_id]
  send_webhook_notification(user, 'This is a test notification from 18xx.games.')
end

MessageBus.subscribe '/turn' do |msg|
  data = msg.data

  users = User.where(id: data['user_ids']).all
  game = Game[data['game_id']]
  minute_ago = (Time.now - 60).to_i

  message = "#{data['type']} in #{game.title} \"#{game.description}\" " \
            "(#{game.round} #{game.turn})\n#{data['game_url']}"
  users.each { |user| send_webhook_notification(user, message) }

  users = users.reject do |user|
    notifications = user.settings['notifications'] || 'none'
    next true if notifications == 'none'
    next true if /@(msn|hotmail|outlook|live|passport)/.match?(user.email.downcase)
    next true if notifications != 'email'
    next false if data['force']
    next true if (Bus[Bus::USER_TS % user.id].to_i || minute_ago) > minute_ago

    email_sent = user.settings['email_sent'] || 0
    email_sent > minute_ago
  end

  next if users.empty?

  html = ASSETS.html(
    'assets/app/mail/turn.rb',
    game_data: game.to_h(include_actions: true, logged_in_user_id: users.first.id),
    game_url: data['game_url'],
  )

  users.each do |user|
    Mail.send(user, "18xx.games Game: #{game.title} - #{game.id} - #{data['type']}", html)
    LOGGER.info("mail sent for game: #{game.id} to user: #{user.id}")
    user.settings['email_sent'] = Time.now.to_i
    user.save
  end
rescue Exception => e # rubocop:disable Lint/RescueException
  puts e.backtrace
  puts e
end

sleep
