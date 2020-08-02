# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module Mail
  API_PATH = 'https://api.elasticemail.com/v2/email/send'

  def self.send(user, subject, html)
    return unless ENV['RACK_ENV'] == 'production'

    uri = URI.parse(API_PATH)
    req = Net::HTTP::Post.new(uri)
    req.body = URI.encode_www_form(
      'apikey' => ENV['ELASTIC_KEY'],
      'subject' => subject,
      'from' => 'no-reply@18xx.games',
      'to' => user.email,
      'bodyHtml' => html,
      'isTransactional' => true,
    )

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req).body
    end
  end
end
