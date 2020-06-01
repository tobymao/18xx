# frozen_string_literal: true

require 'mailjet'

module Mail
  Mailjet.configure do |config|
    config.api_key = ENV['MAIL_JET_KEY']
    config.secret_key = ENV['MAIL_JET_SECRET']
    config.api_version = 'v3.1'
  end

  def self.send(user, subject, html)
    return unless ENV['RACK_ENV'] == 'production'

    Mailjet::Send.create(messages: [
      {
        'From': {
          'Email': 'no-reply@18xx.games',
        },
        'To': [
          {
            'Email': user.email,
          },
        ],
        'Subject': subject,
        'HTMLPart': html,
        'CustomID': '18xx Notification',
      },
    ])
  end
end
