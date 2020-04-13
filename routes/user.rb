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

          login_user(User.create(params))
        end

        not_authorized! unless user

        # POST '/api/user/logout'
        r.post 'logout' do
          session.destroy
          {}
        end

        # POST '/api/user/refresh'
        r.is 'refresh' do
          user.to_h
        end
      end
    end
  end

  def login_user(user)
    session = Session.create(token: SecureRandom.hex, user: user)

    {
      auth_token: session.token,
      user: user.to_h,
    }
  end
end
