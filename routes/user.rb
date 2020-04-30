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
            settings: { notifications: r['notifications'] },
          }.reject { |_, v| v.empty? }

          login_user(User.create(params))
        end

        not_authorized! unless user

        # POST '/api/user/edit'
        r.post 'edit' do
          user.settings = {
            notifications: r.params['notifications'],
          }
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
