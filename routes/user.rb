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
          params = {
            name: r['name'],
            email: r['email'],
            password: r['password'],
          }.reject { |_, v| v.empty? }
          update_settings(r)

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

          { games: Game.home_games(nil, **r.params).map(&:to_h) }
        end

        # POST '/api/user/refresh'
        r.is 'refresh' do
          login_user(user, new_session: false)
        end
      end
    end
  end

  def login_user(user, new_session: true)
    token = (new_session ? Session.create(token: SecureRandom.hex, user: user) : session).token

    {
      auth_token: token,
      user: user.to_h(for_user: true),
      games: Game.home_games(user, **request.params).map(&:to_h),
    }
  end
end
