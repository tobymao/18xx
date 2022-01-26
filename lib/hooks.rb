# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module Hooks
  def self.send(user, message)
    return unless ENV['RACK_ENV'] == 'production'

    uri = URI.parse(user.settings['webhook_url'] || ENV['SLACK_WEBHOOK_URL'])
    req = Net::HTTP::Post.new(uri)
    req.content_type = 'application/json'

    req.body =
      case uri.host
      when 'discord.com', 'discordapp.com'
        JSON.generate(
          content: message,
          allowed_mentions: { parse: ['users'] },
        )
      else
        JSON.generate(text: message)
      end

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req).body
    end
  end
end
