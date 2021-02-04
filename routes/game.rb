# frozen_string_literal: true

class Api
  hash_routes :api do |hr|
    hr.on 'game' do |r|
      # '/api/game/<game_id>/*'
      r.on Integer do |id|
        halt(404, 'Game does not exist') unless (game = Game[id])

        # '/api/game/<game_id>/'
        r.is do
          game_data = game.to_h(include_actions: true, player: user&.id)

          game_data
        end

        # POST '/api/game/<game_id>'
        r.post do
          not_authorized! unless user

          users = game.ordered_players

          # POST '/api/game/<game_id>/join'
          r.is 'join' do
            halt(400, 'Cannot join game because it is full') if users.size >= game.max_players
            halt(400, 'Cannot join because game has started') unless game.status == 'new'

            GameUser.create(game: game, user: user)
            game.players(reload: true)
            game.to_h
          end

          r.is 'leave' do
            halt(400, 'Cannot leave because game has started') unless game.status == 'new'
            halt(400, 'You are not in the game') unless users.any? { |u| u.id == user.id }
            game.remove_player(user)
            game.to_h
          end

          # POST '/api/game/<game_id>/user_settings'
          r.is 'user_settings' do
            game.update_player_settings(user.id, r.params)
            game.save
            game.to_h
          end

          not_authorized! unless users.any? { |u| u.id == user.id } || game.user_id == user.id

          # POST '/api/game/<game_id>/action'
          r.is 'action' do
            halt(400, 'Archived games cannot be changed.') if game.status == 'archived'

            acting, action = nil

            DB.with_advisory_lock(:action_lock, game.id) do
              if game.settings['pin']
                action_id = r.params['id']
                action = r.params.clone
                meta = action['meta']
                halt(400, 'Game missing metadata') unless meta
                halt(400, 'Game out of sync') unless actions_h(game).size + 1 == action_id

                Action.create(
                  game: game,
                  user: user,
                  action_id: action_id,
                  action: action,
                )

                active_players = meta['active_players']
                acting = users.select { |u| active_players.include?(u.id) || active_players.include?(u.name) }

                game.round = meta['round']
                game.turn = meta['turn']
                game.acting = acting.map(&:id)

                game.result = meta['game_result']
                game.status = meta['game_status']

                game.save
              else
                engine = Engine::Game.load(game, actions: actions_h(game))

                r.params['user'] = user.id

                engine = engine.process_action(r.params)
                halt(500, "Illegal action: #{engine.exception}") if engine.exception
                action = engine.raw_actions.last.to_h

                Action.create(
                  game: game,
                  user: user,
                  action_id: action['id'],
                  action: action,
                )

                acting = set_game_state(game, engine, users)
              end
            end

            type, user_ids, force =
              if action['type'] == 'message'
                pinged = users.select do |user|
                  action['message'].include?("@#{user.name}")
                end
                ['Received Message', pinged.map(&:id), false]
              elsif game.status == 'finished'
                ['Game Finished', users.map(&:id), true]
              else
                ['Your Turn', acting.map(&:id), false]
              end

            publish_turn(user_ids, game, r.base_url, type, force) unless user_ids.empty?
            publish("/game/#{game.id}", **action)

            game.to_h
          end

          not_authorized! unless game.user_id == user.id

          # POST '/api/game/<game_id>/delete
          r.is 'delete' do
            game_h = game.to_h.merge(deleted: true)
            game.destroy
            game_h
          end

          # POST '/api/game/<game_id>/start
          r.is 'start' do
            engine = Engine::Game.load(game, actions: [])
            unless game.players.size.between?(*Engine.player_range(engine.class))
              halt(400, 'Player count not supported')
            end

            acting = set_game_state(game, engine, users)
            publish_turn(acting.map(&:id), game, r.base_url, 'Your turn', false)

            game.to_h
          end

          # POST '/api/game/<game_id>/kick
          r.is 'kick' do
            game.remove_player(r.params['id'])
            game.to_h
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
            settings: {
              seed: Random.new_seed % 2**31,
              unlisted: r['unlisted'],
              optional_rules: r['optional_rules'],
            },
            title: title,
            round: Engine.game_by_title(title).new([]).round&.name,
          }

          game = Game.create(params)
          GameUser.create(game: game, user: user)
          game.to_h
        end
      end
    end
  end

  def actions_h(game)
    game.actions(reload: true).map(&:to_h)
  end

  def set_game_state(game, engine, users)
    active_players = engine.active_players_id
    acting = users.select { |u| active_players.include?(u.id) }

    game.round = engine.round.name
    game.turn = engine.turn
    game.acting = acting.map(&:id)

    if engine.finished
      game.result = engine.result
      game.status = 'finished'
    else
      game.result = {}
      game.status = 'active'
    end

    game.save
    acting
  end

  def publish_turn(user_ids, game, url, type, force)
    game_id = game.id

    MessageBus.publish(
      '/turn',
      user_ids: user_ids,
      game_id: game_id,
      game_url: "#{url}/game/#{game_id}",
      type: type,
      force: force,
    )
  end
end
