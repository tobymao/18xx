# frozen_string_literal: true

class Reset < Snabberb::Component
  needs :user
  needs :hash
  needs :base_url

  def render
    h(:div, [
      h(:div, "Hello #{@user['name']},"),
      h(:br),
      h(:div, "You've requested a password reset at #{Time.now}"),
      h(:br),
      h(:div, "Here is your temporary password: #{@hash}"),
      h(:text, 'Please '),
      h(:a, { attrs: { href: "#{@base_url}/reset" } }, 'click here'),
      h(:text, ' to reset your password'),
    ])
  end
end
