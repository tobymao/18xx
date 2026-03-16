# frozen_string_literal: true

class Api
  hash_routes :api do |hr|
    # '/api/user[/*]'
    hr.on 'user' do |r|
      # POST '/api/user[/*]'
      r.post do
        # POST '/api/user/login'
        r.is 'login' do
          halt(400, 'Could not find user') unless (user = User.by_email(r.params['email']))
          halt(401, 'Incorrect password') unless Argon2::Password.verify_password(r.params['password'], user.password)

          login_user(user)
        end

        # POST '/api/user/'
        r.is do
          params = {
            name: r.params['name']&.strip,
            email: r.params['email'],
            password: r.params['password'],
            settings: {
              notifications: r.params['notifications'],
              webhook: r.params['webhook'],
              webhook_url: r.params['webhook_url'],
              webhook_user_id: r.params['webhook_user_id'],
            },
          }.reject { |_, v| v.empty? }

          login_user(User.create(params))
        end

        # POST '/api/user/forgot'
        r.is 'forgot' do
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
          user = User.by_email(r.params['email'])

          halt(400, 'Invalid email!') unless user
          halt(400, 'Invalid code!') unless user.reset_hashes.include?(r.params['hash'])

          user.password = r.params['password']
          user.save

          login_user(user)
        end

        not_authorized! unless user

        # POST '/api/user/edit'
        r.post 'edit' do
          not_authorized! unless user

          if r.params['new_password'] && !r.params['new_password'].strip.empty?
            current_pw = r.params['current_password'].to_s
            new_pw     = r.params['new_password'].to_s
            confirm_pw = r.params['new_password_confirmation'].to_s

            halt(400, 'Current password is required') if current_pw.empty?
            halt(400, 'New password and confirmation do not match') if new_pw != confirm_pw

            halt(401, 'Current password is incorrect') unless Argon2::Password.verify_password(current_pw, user.password)

            user.password = new_pw
          end

          user.update_settings(r.params)
          user.save

          MessageBus.publish('/test_notification', user.id) if r.params['test_webhook_notification']

          response = { user: user.to_h(for_user: true) }

          if r.params['new_password'] && !r.params['new_password'].strip.empty?
            response[:flash_opts] = {
              message: 'Password successfully changed',
              color: 'lightgreen',
            }
          end

          response
        end

        # POST '/api/user/logout'
        r.post 'logout' do
          session.destroy
          clear_cookies!
          { games: Game.home_games(nil, **r.params) }
        end

        # POST '/api/user/login'
        r.is 'delete' do
          MessageBus.publish('/delete_user', user.id)
          clear_cookies!
          {}
        end
      end
    end
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

  def login_user(user)
    token = Session.create(token: SecureRandom.hex, user: user, ip: request.ip).token

    request.response.set_cookie(
      'auth_token',
      value: token,
      expires: Date.today + Session::EXPIRE_TIME,
      domain: nil,
      httponly: true,
      secure: PRODUCTION,
      path: '/',
    )

    {
      user: user.to_h(for_user: true),
      games: Game.home_games(user, **request.params),
    }
  end
end
