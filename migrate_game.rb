# frozen_string_literal: true

require_relative 'lib/engine'

def repair(game, actions, broken_action)
  optionalish_actions=['message', 'buy_company']
  action_idx = actions.index(broken_action)

  if broken_action['type']=='move_token'
    # Move token is now place token.
    broken_action['type']='place_token'
    return :inplace
  elsif broken_action['type']=='pass' && game.is_a?(Engine::Game::G1836Jr30)
    # Shouldn't need to pass when buying trains
    prev_actions = actions[0..action_idx-1]
    prev_action = prev_actions[prev_actions.rindex {|a| !optionalish_actions.include?(a['type']) }]
    puts prev_action
    if prev_action['type']=='buy_train'
      # Delete the pass
      actions.delete(broken_action)
      return :deleted
    end
  end
  raise Exception, 'Cannot fix'
end

def attempt_repair(engine, players, data)
  game=engine.new(
    players,
    id: data['id'],
    actions: [],
  )
  # Locate the break
  filtered_actions, _active_undos = engine.filtered_actions(data['actions'])
  filtered_actions.compact!
  filtered_actions.each.with_index do |action, index|
    action = action.copy(game) if action.is_a?(Engine::Action::Base)
    begin
      game.process_action(action)
    rescue Engine::GameError => e
      puts "Break at #{action}"
      repair_type = repair(game, filtered_actions, action)
      if repair_type == :inplace
        action_idx = data['actions'].index {|a| a['id'] == action['id']}
        data['actions'][action_idx]=action
      else
        # Added or moved actions... destroy undo states
        data['actions']=filtered_actions
      end
      break
    end
  end
end

def migrate_json(filename, fixOne=true)
  while true
    data = JSON.parse(File.read(filename))
    players = data['players'].map { |p| p['name'] }
    begin
      engine = Engine::GAMES_BY_TITLE[data['title']]
      game=engine.new(
        players,
        id: data['id'],
        actions: data['actions'],
      )
    rescue Engine::GameError => e
      # Need to actually repair
      puts "Repairing..."
      attempt_repair(engine, players, data)
      File.write(filename,JSON.pretty_generate(data))

      if fixOne
        puts "Only fixing one problem"
        return if fixOne
      end
    end
    break
  end
  puts "Nothing to do, game works"
end
