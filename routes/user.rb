# frozen_string_literal: true

class Api
  hash_routes :api do |hr|
    # '/api/user[/*]'
    hr.on 'user' do |r|
      # POST '/api/user[/*]'
      r.post do
        # POST '/api/user/login'
        r.is 'login' do
          halt(400, 'Could not find user') unless (user = User.by_email(r['email']))
          halt(401, 'Incorrect password') unless Argon2::Password.verify_password(r['password'], user.password)

          login_user(user)
        end

        # POST '/api/user/'
        r.is do
          halt(400, 'Invalid email address') unless /^[^@\s]+@[^@\s]+\.[^@\s]+$/.match?(r['email'])

          params = {
            name: r['name'],
            email: r['email'],
            password: r['password'],
            settings: { notifications: r['notifications'] },
          }.reject { |_, v| v.empty? }

          login_user(User.create(params))
        end

        # POST '/api/user/forgot'
        r.is 'forgot' do
          user = User.by_email(r['email'])

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
          user = User.by_email(r['email'])

          halt(400, 'Invalid email!') unless user
          halt(400, 'Invalid code!') unless user.reset_hashes.include?(r['hash'])

          user.password = r['password']
          user.save

          login_user(user)
        end

        not_authorized! unless user
        # POST '/api/user/edit'
        r.post 'edit' do
          user.update_settings(r.params)
          user.save
          user.to_h(for_user: true)
        end

        # POST '/api/user/logout'
        r.post 'logout' do
          session.destroy
          clear_cookies!
          { games: Game.home_games(nil, **r.params).map(&:to_h) }
        end

        # POST '/api/user/login'
        r.is 'delete' do
          Game.where(id: user.game_users.map(&:game_id)).delete
          user.destroy
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
    token = Session.create(token: SecureRandom.hex, user: user).token

    request.response.set_cookie(
      'auth_token',
      value: token,
      expires: Date.today + Session::EXPIRE_TIME,
      domain: nil,
      httponly: true,
      secure: true,
      path: '/',
    )

    {
      user: user.to_h(for_user: true),
      games: Game.home_games(user, **request.params).map(&:to_h),
    }
  end
end
