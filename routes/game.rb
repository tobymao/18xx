# frozen_string_literal: true

require_relative '../lib/engine'

class Api
  TURN_CHANNEL = '/turn'

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

          users = game.ordered_players

          # POST '/api/game/<game_id>/join'
          r.is 'join' do
            halt(400, 'Cannot join game because it is full') if users.size >= game.max_players

            GameUser.create(game: game, user: user)
            game.players(reload: true)
            return_and_notify(game)
          end

          not_authorized! unless users.any? { |u| u.id == user.id }

          r.is 'leave' do
            game.remove_player(user)
            return_and_notify(game)
          end

          r.on 'action' do
            engine = Engine::GAMES_BY_TITLE[game.title].new(
              users.map(&:name),
              actions: actions_h(game),
            )
            channel = "/game/#{game.id}"

            # POST '/api/game/<game_id>/action'
            r.is do
              action_id = r.params['id']
              halt(400, 'Game out of sync') unless engine.actions.size + 1 == action_id

              action = engine.process_action(r.params).actions.last.to_h

              Action.create(
                game: game,
                user: user,
                action_id: action_id,
                turn: engine.turn,
                round: engine.round.name,
                action: action,
              )

              active_players = engine.active_players.map(&:name)
              acting = users.select { |u| active_players.include?(u.name) }
              set_game_state(game, acting, engine)

              type, user_ids =
                if r.params['type'] == 'message'
                  ['Received Message', users.map(&:id)]
                else
                  ['Your Turn', acting.map(&:id)]
                end

              MessageBus.publish(
                TURN_CHANNEL,
                user_ids: user_ids,
                game_id: game.id,
                game_url: "#{r.base_url}/game/#{game.id}",
                type: type,
              )
              publish(channel, **action)
              return_and_notify(game)
            end

            # POST '/api/game/<game_id>/action/rollback'
            r.is 'rollback' do
              game.actions.last.destroy
              publish(channel, id: -1)
              return_and_notify(game)
            end
          end

          not_authorized! unless game.user_id == user.id

          # POST '/api/game/<game_id>/delete
          r.is 'delete' do
            game_h = game.to_h.merge(deleted: true)
            game.destroy
            publish('/games', **game_h)
            game_h
          end

          # POST '/api/game/<game_id>/start
          r.is 'start' do
            halt(400, 'Cannot play 1 player') if game.players.size < 2

            game.update(
              settings: { seed: Random.new_seed },
              status: 'active',
              acting: [users.first.id],
            )
            return_and_notify(game)
          end

          # POST '/api/game/<game_id>/kick
          r.is 'kick' do
            game.remove_player(r.params['id'])
            return_and_notify(game)
          end
        end
      end

      r.get do
        { games: Game.home_games(user, **r.params).map(&:to_h) }
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
            round: Engine::GAMES_BY_TITLE[title].new([]).round.name,
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
    publish('/games', **game_h)
    game_h
  end

  def set_game_state(game, acting, engine)
    game.round = engine.round.name
    game.turn = engine.turn
    game.acting = acting.map(&:id)

    if engine.finished
      game.result = engine.result
      game.status = 'finished'
    end

    game.save
  end

  MessageBus.subscribe TURN_CHANNEL do |msg|
    data = msg.data
    users = User.where(id: data['user_ids']).select(:id, :email).all
    game = Game[data['game_id']]

    connected = Session
      .where(user: users)
      .group_by(:user_id)
      .having { max(updated_at) > Time.now - 60 }
      .select(:user_id)
      .all
      .map(&:user_id)

    html = RENDER_HTML.call(
      'assets/js/mail/turn.rb',
      game_data: game.to_h(include_actions: true),
      game_url: data['game_url'],
    )

    users.each do |user|
      next if connected.include?(user.id)

      Mail.send(user, "18xx.games Game: #{game.title} - #{game.id} - #{data['type']}", html)
    end
  end
end
