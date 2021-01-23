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

Bus.configure

ASSETS = Assets.new(precompiled: PRODUCTION)

MessageBus.subscribe '/turn' do |msg|
  data = msg.data

  users = User.where(id: data['user_ids']).all
  game = Game[data['game_id']]
  minute_ago = (Time.now - 60).to_i

  users = users.reject do |user|
    next true if user.settings['notifications'] == false
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
    user.settings['email_sent'] = Time.now.to_i
    user.save
    Mail.send(user, "18xx.games Game: #{game.title} - #{game.id} - #{data['type']}", html)
    LOGGER.info("mail sent for game: #{game.id} to user: #{user.id}")
  end
rescue Exception => e # rubocop:disable Lint/RescueException
  puts e
end

sleep
