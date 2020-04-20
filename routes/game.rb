# frozen_string_literal: true

require_relative '../lib/engine/game/g_1889'

class Api
  hash_routes :api do |hr|
    hr.on 'game' do |r|
      # '/api/game/<game_id>/*'
      r.on Integer do |id|
        halt(404, 'Game does not exist') unless (game = Game[id])

        # '/api/game/<game_id>/'
        r.is do
          game.to_h(include_actions: true)
        end

        # POST '/api/game/<game_id>'
        r.post do
          not_authorized! unless user

          # POST '/api/game/<game_id>/join'
          r.is 'join' do
            halt(400, 'Cannot join game because it is full') if GameUser.where(game: game).count >= game.max_players

            GameUser.create(game: game, user: user)
            return_and_notify(game)
          end

          not_authorized! if GameUser.where(game: game, user: user).empty?

          r.is 'leave' do
            game.remove_player(user)
            return_and_notify(game)
          end

          r.on 'action' do
            engine = Engine::Game::G1889.new(
              game.ordered_players.map(&:name),
              actions: actions_h(game),
            )
            channel = "/game/#{game.id}"

            # POST '/api/game/<game_id>/action'
            r.is do
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
              publish(channel, **action)
            end

            # POST '/api/game/<game_id>//action/rollback'
            r.is 'rollback' do
              game.actions.last.destroy
              publish(channel, actions: actions_h(game))
            end
          end

          not_authorized! unless game.user_id == user.id

          # POST '/api/game/<game_id>/delete
          r.is 'delete' do
            game_h = game.to_h.merge(deleted: true)
            game.destroy
            publish('/games', game_h)
            game_h
          end

          # POST '/api/game/<game_id>/start
          r.is 'start' do
            halt(400, 'Cannot play 1 player') if game.players.size < 2

            game.update(settings: { seed: Random.new_seed }, status: 'active')
            return_and_notify(game)
          end

          # POST '/api/game/<game_id>/kick
          r.is 'kick' do
            game_user = GameUser.find(game: game, user_id: r.params['id'])
            halt(400, 'Cannot kick player') if !game_user || game_user == user

            game_user.destroy
            return_and_notify(game)
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
          return_and_notify(game)
        end
      end
    end
  end

  def actions_h(game)
    game.actions(reload: true).map(&:to_h)
  end

  def return_and_notify(game)
    game_h = game.to_h
    MessageBus.publish('/games', game_h)
    game_h
  end
end
