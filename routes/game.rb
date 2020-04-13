# frozen_string_literal: true

require_relative '../lib/engine/game/g_1889'

class Api
  hash_routes :api do |hr|
    hr.on 'game' do |r|
      # '/api/game/<game_id>/*'
      r.on Integer do |id|
        game = Game[id]

        # '/api/game/<game_id>/'
        r.is do
          game.to_h(include_actions: true)
        end

        # '/api/game/<game_id>/subscribe'
        r.is 'subscribe' do
          room = ROOMS[id]
          q = Queue.new
          room << q

          response['Content-Type'] = 'text/event-stream;charset=UTF-8'
          response['X-Accel-Buffering'] = 'no' # for nginx
          response['Transfer-Encoding'] = 'identity'

          stream(loop: true, callback: -> { on_close(room, q) }) do |out|
            out << "data: #{q.pop}\n\n"
          end
        end

        # '/api/game/<game_id>/refresh'
        r.is 'refresh' do
          { type: 'refresh', data: actions_h(game) }
        end

        # POST '/api/game/<game_id>'
        r.post do
          not_authorized! unless user
          not_authorized! if GameUser.where(game: game, user: user).empty?

          engine = Engine::Game::G1889.new(
            game.players.map(&:name),
            actions: actions_h(game),
          )

          # POST '/api/game/<game_id>/action'
          r.is 'action' do
            action_id = r.params['id']
            halt(400, 'Game out of sync') unless engine.actions.size + 1 == action_id

            params = {
              game: game,
              user: user,
              action_id: action_id,
              turn: engine.turn,
              round: engine.round.name,
            }

            action = engine.process_action(r.params).actions.last.to_h
            params[:action] = action
            Action.create(params)
            notify(id, type: 'action', data: action)
            {}
          end

          # POST '/api/game/<game_id>/rollback'
          r.is 'rollback' do
            game.actions.last.destroy
            notify(id, type: 'refresh', data: actions_h(game))
            {}
          end
        end
      end

      # POST '/api/game[/*]'
      r.post do
        not_authorized! unless user

        # POST '/api/game'
        r.is do
          title = r['title']

          params = {
            user: user,
            description: r['description'],
            max_players: r['max_players'],
            title: title,
            round: Engine::Game::G1889.new([]).round.name,
          }

          game = Game.create(params)
          GameUser.create(game: game, user: user)
          game.to_h
        end

        halt(404, 'Game does not exist') unless (game = Game[r.params['id']])

        # POST '/api/game/join?id=<game_id>'
        r.is 'join' do
          GameUser.create(game: game, user: user) if GameUser.where(game: game).count < game.max_players
          game.to_h
        end

        not_authorized! unless GameUser.where(game: game, user: user).exists

        # POST '/api/game/leave?id=<game_id>'
        r.is 'leave' do
          game.remove_player(user)
          game.to_h
        end

        not_authorized! unless game.user_id == user.id

        # POST '/api/game/delete?id=<game_id>'
        r.is 'delete' do
          game.destroy
          game.to_h
        end

        # POST '/api/game/start?id=<game_id>'
        r.is 'start' do
          game.update(status: 'active')
          game.to_h
        end
      end
    end
  end

  def actions_h(game)
    game.actions(reload: true).map(&:to_h)
  end
end
