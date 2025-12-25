# frozen_string_literal: true

class Api
  hash_routes :api do |hr|
    hr.on 'game' do |r|
      # '/api/game/<game_id>/*'
      r.on Integer do |id|
        halt(404, 'Game does not exist') unless (game = Game[id])

        # '/api/game/<game_id>/'
        r.is do
          game_data = game.to_h(include_actions: true, logged_in_user_id: user&.id)

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

            if users.size == game.max_players - 1
              # Generate a message to the game owner
              type = 'Game Full'
              user_ids = [game.user_id]
              force = true
              publish_turn(user_ids, game, r.base_url, type, force)
            end

            GameUser.create(game: game, user: user)
            game.players(reload: true)
            game.to_h
          end

          # POST '/api/game/<game_id>/leave'
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

          not_authorized! if users.none? { |u| u.id == user.id } && game.user_id != user.id

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
                acting.delete(user)

                if game.status != 'finished' && meta['game_status'] == 'finished'
                  meta['finished_at'] = Time.now
                  meta['manually_ended'] = true unless meta.key?('manually_ended')

                  # If the game_result keys are not user ids, fix them up here
                  if meta['game_result'].keys.any? { |key| key.to_i.to_s != key }
                    meta['game_result'].transform_keys! { |name| game.players.find { |p| p.name == name }.id.to_s }
                  end
                else
                  meta['finished_at'] = nil
                  meta['manually_ended'] = nil
                end

                game.result = meta['game_result']
                game.status = meta['game_status']
                game.finished_at = meta['finished_at']
                game.manually_ended = meta['manually_ended']

                game.save
              else
                engine = Engine::Game.load(game, actions: actions_h(game))
                prev = acting_users(engine, users)

                r.params['user'] = user.id

                engine = engine.process_action(r.params, validate_auto_actions: true)
                halt(500, "Illegal action: #{engine.exception}") if engine.exception
                action = engine.raw_actions.last.to_h

                Action.create(
                  game: game,
                  user: user,
                  action_id: action['id'],
                  action: action.dup,
                )

                acting = set_game_state(game, engine, users) - prev
              end
            end

            other_users = users.reject { |u| u.id == user&.id }
            type, user_ids, force =
              if action['type'] == 'message'
                pinged = if action['message'].include?('@all')
                           other_users
                         else
                           other_users.select do |u|
                             action['message'].include?("@#{u.name}")
                           end
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
            halt(400, 'Player count not supported') unless game.players.size.between?(*engine.class::PLAYER_RANGE)

            acting = set_game_state(game, engine, users)
            publish_turn(acting.map(&:id), game, r.base_url, 'Your turn', false)

            game.to_h
          end

          # POST '/api/game/<game_id>/kick
          r.is 'kick' do
            game.remove_player(r.params['id'])

            game.to_h
          end

          # POST '/api/game/<game_id>/player_order
          r.is 'player_order' do
            game.settings['player_order'] = r.params['player_order']
            game.save

            game.to_h
          end
        end
      end

      r.get do
        { games: Game.home_games(user, **r.params) }
      end

      # POST '/api/game[/*]'
      r.post do
        not_authorized! unless user

        # POST '/api/game'
        r.is do
          title = r.params['title']

          params = {
            user: user,
            description: r.params['description'],
            min_players: r.params['min_players'],
            max_players: r.params['max_players'],
            settings: {
              seed: (r.params['seed'] || Random.new_seed) % (2**31),
              player_order: r.params['player_order'],
              unlisted: r.params['unlisted'],
              optional_rules: r.params['optional_rules'],
              auto_routing: r.params['auto_routing'],
              use_engine_v2: r.params['use_engine_v2'],
              is_async: r.params['async'],
            },
            title: title,
            round: 'Unstarted',
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
    acting = acting_users(engine, users)

    game.round = engine.round.name
    game.turn = engine.turn
    game.acting = acting.map(&:id)

    if engine.finished
      game.result = engine.result
      game.finished_at = Time.now
      game.manually_ended = engine.manually_ended
      game.status = 'finished'
    else
      game.result = {}
      game.finished_at = nil
      game.manually_ended = nil
      game.status = 'active'
    end

    game.save
    acting
  end

  def acting_users(engine, users)
    active_players = engine.active_players_id
    users.select { |u| active_players.include?(u.id) }
  end

  def publish_turn(user_ids, game, url, type, force)
    return if game.settings['pin']

    MessageBus.publish(
      '/turn',
      user_ids: user_ids,
      game_id: game.id,
      game_url: "#{url}/game/#{game.id}",
      type: type,
      force: force,
    )
  end
end
