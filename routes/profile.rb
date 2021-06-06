# frozen_string_literal: true

class Api
  hash_routes :api do |hr|
    hr.on 'profile' do |r|
      # '/api/profile/*'
      r.is do
        # '/api/profile'
        r.get do
          not_authorized! unless user

          # '/api/profile'
          r.is do
            { games: Game.home_games(user, **request.params).map(&:to_h) }
          end
        end
      end
    end
  end
end
