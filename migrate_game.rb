# frozen_string_literal: true

require_relative 'lib/engine'

def repair(data, broken_action)
  if broken_action['type']=='move_token'
    broken_action['type']='place_token'
    return :inplace
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
      repair_type = repair(filtered_actions, action)
      if repair_type == :inplace
        data['actions'][action['id']-1]=action
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

      break if fixOne
    end
    break
  end
  puts "Nothing to do, game works"
end
