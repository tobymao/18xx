# frozen_string_literal: true

class Verify < Snabberb::Component
  needs :user
  needs :link

  def render
    h(:div, [
      h(:div, "Hello #{@user['name']},"),
      h(:br),
      h(:div, 'Welcome to 18xx.games! Please verify your email to activate your account.'),
      h(:br),
      h(:text, 'Please '),
      h(:a, { attrs: { href: @link } }, 'click here'),
      h(:text, ' to verify your email.'),
      h(:br),
      h(:br),
      h(:div, 'To make sure you receive this and future emails (verification, password resets, ' \
              'game notifications), please add no-reply@18xx.games to your contacts or email ' \
              'allowlist / safe-sender list so our messages are not blocked or sent to spam.'),
    ])
  end
end
