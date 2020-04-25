# frozen_string_literal: true

require 'net/http'

module Mail
  END_POINT = URI.parse('https://api.mailgun.net/v3/mg.18xx.games/messages')

  def self.send(user, subject, html)
    return unless ENV['RACK_ENV'] == 'production'

    req = Net::HTTP::Post.new(END_POINT)
    req.basic_auth('api', ENV['MAIL_GUN_KEY'])
    req.body = URI.encode_www_form(
      'from': 'no-reply@18xx.games',
      'subject': subject,
      'html': html,
      'to': user.email,
    )

    Net::HTTP.start(END_POINT.hostname, END_POINT.port, use_ssl: true) do |http|
      http.request(req)
    end
  end
end
