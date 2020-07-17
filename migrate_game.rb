# frozen_string_literal: true
# rubocop:disable all

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
  action = broken_action['original_id'] || broken_action['id']
  puts "http://18xx.games/game/#{game.id}?action=#{action}"
  puts game.active_step
  prev_actions = actions[0..action_idx - 1]
  prev_action = prev_actions[prev_actions.rindex { |a| !optionalish_actions.include?(a['type']) }]
  next_actions = actions[action_idx + 1..]
  next_action = next_actions.find { |a| !optionalish_actions.include?(a['type']) }

  if broken_action['type'] == 'move_token'
    # Move token is now place token.
    broken_action['type'] = 'place_token'
    return :inplace
  elsif broken_action['type'] == 'pass'
    if game.active_step.is_a?(Engine::Step::Route) || game.active_step.is_a?(Engine::Step::Train)
      # Lay token sometimes needed pass when it shouldn't have
      actions.delete(broken_action)
      return :deleted
    end
    if game.active_step.is_a?(Engine::Step::Track)
      # some games of 1889 didn't skip buy train
      actions.delete(broken_action)
      return :deleted
    end

    if game.active_step.is_a?(Engine::Round::Stock)
      # some games of 1889 didn't skip the buy companies step correctly
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
  elsif broken_action['type'] == 'lay_tile'
    if game.active_step.is_a?(Engine::Step::BuyCompany)
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return :inserted
    end
    if game.active_step.is_a?(Engine::Step::Train) && game.active_step.actions(game.active_step.current_entity).include?('pass')
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return :inserted
    end
    puts prev_action
    if game.active_step.is_a?(Engine::Step::Route) and prev_action['type'] == 'pass'
      actions.delete(prev_action)
      return :deleted
    end
    if game.active_step.is_a?(Engine::Step::Token) and prev_action['type'] == 'pass'
      actions.delete(prev_action)
      return :deleted
    end
  elsif broken_action['type'] == 'buy_train'
    if prev_action['type'] == 'pass' && game.active_step.is_a?(Engine::Step::Track)
      # Remove the pass, as it was probably meant for a token
      actions.delete(prev_action)
      return :deleted
    end
    if game.active_step.is_a?(Engine::Step::DiscardTrain) && next_action['type'] == 'discard_train'
      switch_actions(original_actions, broken_action, next_action)
      return :inplace
    end
    if game.active_step.is_a?(Engine::Step::Track)
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return :inserted
    end
    if game.active_step.is_a?(Engine::Step::Token)
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return :inserted
    end
    if game.active_step.is_a?(Engine::Step::BuyCompany) && prev_action['type'] == 'pass'
      actions.delete(prev_action)
      return :deleted
    end
  elsif broken_action['type'] == 'run_routes'
    if game.active_step.is_a?(Engine::Step::Dividend) && prev_action['type'] == 'run_routes'
      actions.delete(prev_action)
      return :deleted
    end
    if game.active_step.is_a?(Engine::Step::Track)
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return :inserted
    end
    if game.active_step.is_a?(Engine::Step::Token)
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return :inserted
    end
  elsif game.active_step.is_a?(Engine::Step::Token)
    pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
    actions.insert(action_idx, pass)
    return :inserted
  elsif game.active_step.is_a?(Engine::Step::TrackAndToken)
    if ['buy_shares','sell_shares'].include?(broken_action['type']) and prev_action['type'] == 'pass'
      # Stray pass from buy companies
      actions.delete(prev_action)
      return :deleted
    end
    pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
    actions.insert(action_idx, pass)
    return :inserted
  elsif broken_action['type'] == 'dividend' and broken_action['entity_type'] == 'minor'
    actions.delete(broken_action)
    return :deleted
  end

  puts "Game think it's #{game.active_step.current_entity.id} turn"
  raise Exception, "Cannot fix http://18xx.games/game/#{game.id}?action=#{action}"
end

def attempt_repair(game, actions)
  game.instance_variable_set(:@loading, true)
  # Locate the break
  filtered_actions, _active_undos = game.class.filtered_actions(actions)
  filtered_actions.compact!
  filtered_actions.each.with_index do |action, _index|
    action = action.copy(game) if action.is_a?(Engine::Action::Base)
    begin
      game.process_action(action)
    rescue Exception => e
      puts "Break at #{e} #{action}"
      repair_type = repair(game, actions, filtered_actions, action)
      if repair_type == :inplace
        return actions
      else
        # Added or moved actions... destroy undo states and renumber.
        filtered_actions.each_with_index do |a, idx|
          a['original_id'] = a['id'] unless a.include?('original_id')
          a['id'] = idx + 1
        end
        return filtered_actions
      end
    end
  end
end

def migrate_data(data, fix_one = true)
  fixed = false
  loop do
    players = data['players'].map { |p| p['name'] }
    begin
      engine = Engine::GAMES_BY_TITLE[data['title']]
      engine.new(
        players,
        id: data['id'],
        actions: data['actions'],
      )
      break
    rescue Exception => e
      # Need to actually repair
      puts "Repairing... #{e}"
      game = engine.new(
        players,
        id: data['id'],
        actions: [],
      )
      begin
        data['actions'] = attempt_repair(game, data['actions'])
      rescue Exception => e
        puts 'Failed to fix :(', e
        return data
      end
      fixed = true

      if fix_one
        puts 'Only fixing one problem'
        return data
      end
    end
  end
  return data if fixed
end

# This doesn't write to the database
def migrate_db_actions(data, fix_one = false)
  actions = data.actions.map(&:to_h)
  fixed = false
  loop do
    engine = Engine::GAMES_BY_TITLE[data.title]
    engine.new(
      data.ordered_players.map(&:name),
      id: data.id,
      actions: actions,
    )
    break
  rescue Exception => e
    # Need to actually repair
    puts "Repairing... #{e}"
    game = engine.new(
      data.ordered_players.map(&:name),
      id: data.id,
      actions: [],
    )
    begin
      actions = attempt_repair(game, actions)
    rescue Exception => e
      puts 'Something went wrong', e
      #raise e
      return actions
    end
    fixed = true

    if fix_one
      puts 'Only fixing one problem'
      return actions
    end
  end
  actions
end

def migrate_json(filename, fix_one = true)
  data = migrate_data(JSON.parse(File.read(filename)), fix_one)
  if data
    File.write(filename, JSON.pretty_generate(data))
  else
    puts 'Nothing to do, game works'
  end
end

def migrate_db_to_json(id, filename)
  game = Game[id]
  json = game.to_h(include_actions: true)
  json['actions'] = migrate_db_actions(game)
  File.write(filename, JSON.pretty_generate(json))
end
