# frozen_string_literal: true

require_relative '../lib/engine/game/g_1889'

class Api
  hash_routes :api do |hr|
    hr.on 'game' do |r|
      r.on Integer do |id|
        game = Game[id]

        r.is do
          game.to_h(include_actions: true)
        end

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

        r.is 'refresh' do
          { type: 'refresh', data: actions_h(game) }
        end

        r.post do
          r.halt 403 unless GameUser.where(game: game, user: user).exists

          engine = Engine::Game::G1889.new(
            game.players.map(&:name),
            actions: actions_h(game),
          )

          r.is 'action' do
            params = {
              game: game,
              action_id: r.params['id'],
              turn: engine.turn,
              round: engine.round.name,
            }
            action = engine.process_action(r.params).actions.last.to_h
            params[:action] = action
            Action.create(params)
            notify(id, type: 'action', data: action)
            {}
          end

          r.is 'rollback' do
            game.actions.last.destroy
            notify(id, type: 'refresh', data: actions_h(game))
            {}
          end
        end
      end

      r.post do
        r.halt 403 unless user

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

        r.halt 404 unless (game = Game[r.params['id']])

        r.is 'join' do
          GameUser.create(game: game, user: user) if GameUser.where(game: game).count < game.max_players
          game.to_h
        end

        r.halt 403 unless GameUser.where(game: game, user: user).exists

        r.is 'leave' do
          game.remove_player(user)
          game.to_h
        end

        r.halt 403 unless game.user_id == user.id

        r.is 'delete' do
          game.destroy
          game.to_h
        end

        r.is 'start' do
          game.update(status: 'active')
          game.to_h
        end
      end
    end
  end

  def actions_h(game)
    game.actions.map(&:to_h)
  end
end
