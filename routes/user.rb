# frozen_string_literal: true

require 'net/http'

class Api
  hash_routes :api do |hr|
    # '/api/user[/*]'
    hr.on 'user' do |r|
      # POST '/api/user[/*]'
      r.post do
        # POST '/api/user/login'
        r.is 'login' do
          halt(403, 'Access denied') if Ban.banned_ip?(request.ip)
          verify_turnstile!
          halt(400, 'Could not find user') unless (user = User.by_email(r.params['email']))
          halt(401, 'Incorrect password') unless Auth.password_match?(user.password, r.params['password'])
          halt(403, 'This account has been banned') if Ban.banned_account?(user.id)
          unless user.verified?
            halt(401, 'Please verify your email before logging in. Check your spam folder and add ' \
                      'no-reply@18xx.games to your allowlist, or use "Resend verification email" below.')
          end

          login_user(user)
        end

        # POST '/api/user/'
        r.is do
          halt(403, 'Access denied') if Ban.banned_ip?(request.ip)
          verify_turnstile!
          email = r.params['email']
          # Static blocklist first (free); fall through to the MX-backend check
          # (one DNS lookup) only if it passes, to catch rotating-domain providers.
          if DisposableEmail.blocked?(email) || DisposableEmail.mx_blocked?(email)
            halt(400, 'Disposable email addresses are not allowed. Please use a permanent email address.')
          end

          user = User.new
          user.password = r.params['password'] unless r.params['password']&.strip&.empty?
          user.update_settings(r.params)
          user.settings['verified'] = false
          user.save

          send_verification_email(user, r.base_url)

          {
            flash_opts: {
              message: 'Account created! Check your email (including spam) to verify your account ' \
                       'before logging in. Add no-reply@18xx.games to your allowlist so our emails ' \
                       'are not blocked.',
              color: 'lightgreen',
            },
          }
        end

        # POST '/api/user/forgot'
        r.is 'forgot' do
          verify_turnstile!
          user = User.by_email(r.params['email'])

          halt(400, 'Could not find email') unless user
          halt(400, "You've recently requested a password reset!") unless user.can_reset?

          user.settings['last_password_reset'] = Time.now.to_i
          user.save

          html = ASSETS.html(
            'assets/app/mail/reset.rb',
            user: user.to_h,
            hash: user.reset_hashes[1],
            base_url: r.base_url
          )
          # Remove once we verify email sends as expected
          Mail.send(user, '18xx.games Forgotten Password', html)
          { result: true }
        end

        # POST '/api/user/reset'
        r.is 'reset' do
          verify_turnstile!
          user = User.by_email(r.params['email'])

          halt(400, 'Invalid email!') unless user
          halt(400, 'Invalid code!') unless user.reset_hashes.include?(r.params['hash'])

          user.password = r.params['password']
          user.save

          Session.where(user_id: user.id).delete

          login_user(user)
        end

        # POST '/api/user/resend_verification'
        r.is 'resend_verification' do
          verify_turnstile!
          user = User.by_email(r.params['email'].to_s)
          send_verification_email(user, r.base_url) if user && !user.verified? && user.can_resend_verification?
          { result: true }
        end

        not_authorized! unless user

        # POST '/api/user/edit'
        r.post 'edit' do
          not_authorized! unless user

          password_changed = r.params['new_password'] && !r.params['new_password'].strip.empty?

          if password_changed
            current_pw = r.params['current_password'].to_s
            new_pw     = r.params['new_password'].to_s
            confirm_pw = r.params['new_password_confirmation'].to_s

            halt(400, 'Current password is required') if current_pw.empty?
            halt(400, 'New password and confirmation do not match') if new_pw != confirm_pw

            halt(401, 'Current password is incorrect') unless Auth.password_match?(user.password, current_pw)

            user.password = new_pw
          end

          user.update_settings(r.params)
          user.save

          if password_changed
            Session.where(user_id: user.id).delete
            issue_session(user)
          end

          MessageBus.publish('/test_notification', user.id) if r.params['test_webhook_notification']

          response = { user: user.to_h(for_user: true) }
          response[:flash_opts] = { message: 'Password successfully changed', color: 'lightgreen' } if password_changed

          response
        end

        # POST '/api/user/logout'
        r.post 'logout' do
          session.destroy
          clear_cookies!
          { games: Game.home_games(nil, **r.params) }
        end

        # POST '/api/user/delete'
        r.is 'delete' do
          # A consented account must supply its password to delete (defense-in-depth
          # for an irreversible action). An un-consented account is still at the
          # consent gate, where deletion is the decline/escape hatch, so no password
          # is required there.
          if user.settings['consent'] && !Auth.password_match?(user.password, r.params['password'])
            halt(401, 'Incorrect password')
          end

          MessageBus.publish('/delete_user', user.id)
          clear_cookies!
          {}
        end
      end
    end
  end

  # Cloudflare Turnstile check for the unauthenticated auth endpoints, to stop
  # scripted signup/login abuse. Skipped in the test env; if the verify request
  # itself errors it fails closed in production, open elsewhere.
  def verify_turnstile!
    return if ENV['RACK_ENV'] == 'test'

    token = request.params['cf_turnstile_response'].to_s
    halt(400, 'Please complete the captcha') if token.empty?

    ok =
      begin
        uri = URI('https://challenges.cloudflare.com/turnstile/v0/siteverify')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = 3
        http.read_timeout = 3
        req = Net::HTTP::Post.new(uri)
        req.set_form_data('secret' => TURNSTILE_SECRET, 'response' => token, 'remoteip' => request.ip)
        data = JSON.parse(http.request(req).body)
        # In prod also bind the token to our own hostname, so a token minted against
        # our public site key on some other page can't be replayed here.
        data['success'] == true && (!PRODUCTION || TURNSTILE_HOSTS.include?(data['hostname']))
      rescue StandardError => e
        API_LOGGER.error("Turnstile verify error: #{e}")
        !PRODUCTION
      end

    halt(403, 'Captcha check failed — please try again') unless ok
  end

  def clear_cookies!
    request.response.set_cookie(
      'auth_token',
      value: nil,
      expires: Date.today - 1000,
      domain: nil,
      path: '/',
    )
  end

  def send_verification_email(user, base_url)
    user.settings['last_verification_sent'] = Time.now.to_i
    user.save

    link = "#{base_url}/verify?email=#{Rack::Utils.escape(user.email)}&hash=#{user.verification_hashes[1]}"
    html = ASSETS.html('assets/app/mail/verify.rb', user: user.to_h, link: link)
    Mail.send(user, '18xx.games Verify Your Email', html)
  rescue StandardError => e
    API_LOGGER.error("Failed to send verification email to #{user&.email}: #{e}")
  end

  def issue_session(user)
    token = Session.create(token: SecureRandom.hex, user: user, ip: request.ip).token

    request.response.set_cookie(
      'auth_token',
      value: token,
      expires: Date.today + Session::EXPIRE_TIME,
      domain: nil,
      httponly: true,
      secure: PRODUCTION,
      same_site: :lax,
      path: '/',
    )
  end

  def login_user(user)
    issue_session(user)

    {
      user: user.to_h(for_user: true),
      games: Game.home_games(user, **request.params),
    }
  end
end
