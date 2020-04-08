# frozen_string_literal: true

class Api
  route 'user' do |r|
    r.post 'refresh' do
      { user: { name: user&.name } }
    end

    r.post 'login' do
      user = User.by_email(r['email'])
      login_user(user) if user && Argon2::Password.verify_password(r['password'], user.password)
      ''
    end

    r.post 'logout' do
      session.destroy
      ''
    end

    r.post do
      params = {
        name: r['name'],
        email: r['email'],
        password: r['password'],
      }

      login_user(User.create(params))
    end
  end

  def login_user(user)
    session = Session.create(token: SecureRandom.hex, user: user)

    {
      auth_token: session.token,
      user: { name: user.name }
    }
  end
end
