# frozen_string_literal: true

require 'logger'
require 'webpush'
require 'json'
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

  html = ASSETS.html(
    'assets/app/mail/turn.rb',
    game_data: game.to_h(include_actions: true),
    game_url: data['game_url'],
  )

  users.each do |user|
    unless data['force']
      next if (Bus[Bus::USER_TS % user.id].to_i || 0) > minute_ago
      next if (user.settings['email_sent'] || 0) > minute_ago
    end

    if user.settings['notifications']
      user.settings['email_sent'] = Time.now.to_i
      Mail.send(user, "18xx.games Game: #{game.title} - #{game.id} - #{data['type']}", html)
      LOGGER.info("mail sent for game: #{game.id} to user: #{user.id}")
    end

    user.settings['webpush_subscriptions'] ||= []

    user.settings['webpush_subscriptions'].each do |params|
      user.settings['email_sent'] = Time.now.to_i

      Webpush.payload_send(
        message: {
          title: "18xx.games - #{data['type']}",
          body: "18xx.games Game: #{game.title} - #{game.id} - #{data['type']}",
          url: data['relative_url'],
        }.to_json,
        endpoint: params['subscription']['endpoint'],
        p256dh: params['subscription']['keys']['p256dh'],
        auth: params['subscription']['keys']['auth'],
        vapid: {
          subject: 'https://18xx.games',
          public_key: ENV['VAPID_PUBLIC_KEY'],
          private_key: ENV['VAPID_PRIVATE_KEY'],
        },
      )
    end

    user.save
  end
rescue Exception => e # rubocop:disable Lint/RescueException
  puts e
end

sleep
