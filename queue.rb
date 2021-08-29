# frozen_string_literal: true

require 'logger'
require 'require_all'
require_relative 'models'
require_rel './models'
require_relative 'lib/assets'
require_relative 'lib/bus'
require_relative 'lib/hooks'
require_relative 'lib/mail'

PRODUCTION = ENV['RACK_ENV'] == 'production'

LOGGER = Logger.new($stdout)

Bus.configure

ASSETS = Assets.new(precompiled: PRODUCTION)

MessageBus.subscribe '/turn' do |msg|
  data = msg.data

  users = User.where(id: data['user_ids']).all
  game = Game[data['game_id']]
  minute_ago = (Time.now - 60).to_i

  users.each do |user|
    next if user.settings['notifications'] != 'webhook'
    next if (user.settings['webhook_user_id']&.strip || '') == ''

    begin
      message = "<@#{user.settings['webhook_user_id']}> #{data['type']} in #{game.title} \"#{game.description}\" " \
                "(#{game.round} #{game.turn})\n#{data['game_url']}"
      Hooks.send(user, message)
    rescue Exception => e # rubocop:disable Lint/RescueException
      puts e.backtrace
      puts e
    end
  end

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
    game_data: game.to_h(include_actions: true),
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
