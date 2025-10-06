# frozen_string_literal: true

require 'json'

require_relative 'scripts_helper'
require_relative 'validate'

# Fixes two endgame-related issues:
# - a game's `result` in the DB is different than what the Engine computes
# - a game has actions after the game has finished
def migrate_endgames(ids, page_size: 50, filename: 'migrate_endgames.json')
  data = { 'games' => [], 'summary' => {} }

  Array(ids).each_slice(page_size) do |ids_|
    Game.eager(:user, :players, :actions).where(id: ids_).all.each do |game|
      run_game_kwargs = {
        strict: false,
        silent: false,
        trace: true,
        validate_result: false,
        return_engine: true,
      }

      # run game in engine
      game_data = run_game(game, **run_game_kwargs)

      game_data['old_db_result'] = transform_result(game.result)
      game_data['result_updated'] = false
      game_data['status_updated'] = false

      # remove actions after the game is over
      if /GameIsOver/.match?(game_data['exception'])
        broken_action = game_data['broken_action']
        db_broken_action_model = game.actions.find { |a| a.action_id == broken_action['id'] }

        db_broken_action = db_broken_action_model.action
        db_broken_action['id'] = db_broken_action_model.action_id
        db_broken_action['created_at'] = db_broken_action_model.created_at.to_i
        if db_broken_action != broken_action
          raise "Got broken action from engine: #{broken_action}\nCould not match with action from DB: #{db_broken_action}"
        end

        index = game.actions.index(db_broken_action_model)
        remove, keep = game.actions.partition.with_index { |a, i| i >= index && a.action['type'] != 'message' }

        remove << keep.pop while keep.last.action['type'].include?('program')

        # reprocess the game
        game_data = run_game(game, keep.map(&:to_h), **run_game_kwargs)
        game_data['old_db_result'] = transform_result(game.result)
        game_data['result_updated'] = false
        game_data['status_updated'] = false
        if game_data['exception']
          puts "game #{game.id} is still broken when processing without the actions, won't migrate..."
          data['games'] << game_data.except('engine')
          next
        end
        unless game_data['engine'].finished
          puts "game #{game.id} is still broken when processing without the actions, won't migrate..."
          data['games'] << game_data.except('engine')
          next
        end

        # the game is good after processing without the `remove` actions, so now
        # we can remove them
        DB.transaction do
          remove.each do |action|
            Action.where(game_id: action.game_id, action_id: action.action_id).delete
          end
        end
        # re-load game from DB with freshly pruned actions list
        game = Game[game.id]

        game_data['actions_deleted'] = true
      end

      # update status ("finished" vs "active")
      if game_data['game_finished'] != (game.status == 'finished')
        game.status = game_data['game_finished'] ? 'finished' : 'active'
        game.save
        game_data['status_updated'] = true
      end
      game_data['status'] = game.status

      # update stored result, add delta to JSON report
      game_data['result'] = transform_result(game_data['result'])
      if game_data['result'] != game_data['old_db_result']
        delta =
          game_data['result'].map do |k, v|
            delta = (v - game_data['old_db_result'][k])
            [k, delta] unless delta.zero?
          end
        game_data['result_delta'] = delta.compact.sort_by { |_k, v| v.abs }.reverse.to_h

        game.result = game_data['result']
        game.save
        game_data['result_updated'] = true
      end

      # TODO? exclude games where ranking changed from ELO?
      engine_rankings = player_rankings(game_data['result'])
      db_rankings = player_rankings(game_data['old_db_result'])
      if engine_rankings != db_rankings
        game_data['rankings'] = engine_rankings
        game_data['db_rankings'] = db_rankings
      end

      # save all the data for report
      data['games'] << game_data.except('engine')
    end
  end

  data['summary'] = {
    'total' => data['games'].size,
    'actions_deleted' => data['games'].count { |g| g['actions_deleted'] },
    'result_updated' => data['games'].count { |g| g['result_updated'] },
    'status_updated' => data['games'].count { |g| g['status_updated'] },
  }

  File.write(filename, JSON.pretty_generate(data))
end

# sort result with high score first, all player IDs as strings for the keys
def transform_result(result)
  result.map { |k, v| [k.to_s, v.to_i] }.sort_by { |id, v| [v, -id.to_i] }.reverse.to_h
end

# return Hash: player_id => ranking, where winner=1
def player_rankings(result)
  scores = result.values.uniq.sort.reverse
  result.transform_values { |s| scores.index(s) + 1 }
end
