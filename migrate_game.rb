# frozen_string_literal: true

require_relative 'lib/engine'

def switch_actions(actions, first, second)
  first_idx = actions.index(first)
  second_idx = actions.index(second)

  id = second['id']
  second['id'] = first['id']
  first['id'] = id

  actions[first_idx] = second
  actions[second_idx] = first
end

def repair(game, original_actions, actions, broken_action)
  optionalish_actions = %w[message buy_company]
  action_idx = actions.index(broken_action)

  prev_actions = actions[0..action_idx - 1]
  prev_action = prev_actions[prev_actions.rindex { |a| !optionalish_actions.include?(a['type']) }]
  next_actions = actions[action_idx + 1..]
  next_action = next_actions.find { |a| !optionalish_actions.include?(a['type']) }
  puts game.active_step
  puts next_action
  if broken_action['type'] == 'move_token'
    # Move token is now place token.
    broken_action['type'] = 'place_token'
    return :inplace
  elsif broken_action['type'] == 'pass'
    if next_action['type'] == 'run_routes'
      # Lay token sometimes needed pass when it shouldn't have
      actions.delete(broken_action)
      return :deleted
    end

    if game.is_a?(Engine::Game::G1836Jr30)
      # Shouldn't need to pass when buying trains
      if prev_action['type'] == 'buy_train'
        # Delete the pass
        actions.delete(broken_action)
        return :deleted
      end
    end
  elsif game.active_step.is_a?(Engine::Step::DiscardTrain)
    if next_action['type'] == 'discard_train'
      switch_actions(original_actions, broken_action, next_action)
      return :inplace
    end
  elsif game.active_step.is_a?(Engine::Step::TrackAndToken)
    pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
    actions.insert(action_idx, pass)
    return :inserted
  end
  raise Exception, 'Cannot fix'
end

def attempt_repair(engine, players, data)
  game = engine.new(
    players,
    id: data['id'],
    actions: [],
  )
  game.instance_variable_set(:@loading, true)
  # Locate the break
  filtered_actions, _active_undos = engine.filtered_actions(data['actions'])
  filtered_actions.compact!
  filtered_actions.each.with_index do |action, _index|
    action = action.copy(game) if action.is_a?(Engine::Action::Base)
    begin
      game.process_action(action)
    rescue Engine::GameError => e
      puts "Break at #{e} #{action}"
      repair_type = repair(game, data['actions'], filtered_actions, action)
      if repair_type != :inplace
        # Added or moved actions... destroy undo states and renumber.
        filtered_actions.each_with_index do |a, idx|
          a['original_id'] = a['id'] unless a.include?('original_id')
          a['id'] = idx + 1
        end
        data['actions'] = filtered_actions
      end
      break
    end
  end
end

def migrate_json(filename, fix_one = true)
  loop do
    data = JSON.parse(File.read(filename))
    players = data['players'].map { |p| p['name'] }
    begin
      engine = Engine::GAMES_BY_TITLE[data['title']]
      engine.new(
        players,
        id: data['id'],
        actions: data['actions'],
      )
    rescue Engine::GameError => e
      # Need to actually repair
      puts "Repairing... #{e}"
      attempt_repair(engine, players, data)
      File.write(filename, JSON.pretty_generate(data))

      if fix_one
        puts 'Only fixing one problem'
        return if fix_one
      end
    end
    break
  end
  puts 'Nothing to do, game works'
end
