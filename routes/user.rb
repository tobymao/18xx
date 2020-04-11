# frozen_string_literal: true

class Api
  hash_routes :api do |hr|
    hr.on 'user' do |r|
      r.post do
        r.is 'login' do
          user = User.by_email(r['email'])
          r.halt(403) unless Argon2::Password.verify_password(r['password'], user&.password)

          login_user(user)
        end

        r.is do
          params = {
            name: r['name'],
            email: r['email'],
            password: r['password'],
          }

          login_user(User.create(params))
        end

        r.halt(403) unless user

        r.post 'logout' do
          session.destroy
          ''
        end

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
