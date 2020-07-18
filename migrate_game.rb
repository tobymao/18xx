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

# Returns either the actions that are modified inplace, or nil if inserted/deleted
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
    return [broken_action]
  elsif broken_action['type'] == 'pass'
    if game.active_step.is_a?(Engine::Step::Route) || game.active_step.is_a?(Engine::Step::Train)
      # Lay token sometimes needed pass when it shouldn't have
      actions.delete(broken_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::Track)
      # some games of 1889 didn't skip buy train
      actions.delete(broken_action)
      return
    end

    if game.active_step.is_a?(Engine::Round::Stock)
      # some games of 1889 didn't skip the buy companies step correctly
      actions.delete(broken_action)
      return
    end
    if game.is_a?(Engine::Game::G1836Jr30)
      # Shouldn't need to pass when buying trains
      if prev_action['type'] == 'buy_train'
        # Delete the pass
        actions.delete(broken_action)
        return
      end
    end
  elsif broken_action['type'] == 'lay_tile'
    if game.active_step.is_a?(Engine::Step::BuyCompany)
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return
    end
    if game.active_step.is_a?(Engine::Step::Train) && game.active_step.actions(game.active_step.current_entity).include?('pass')
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return
    end
    puts prev_action
    if game.active_step.is_a?(Engine::Step::Route) and prev_action['type'] == 'pass'
      actions.delete(prev_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::Token) and prev_action['type'] == 'pass'
      actions.delete(prev_action)
      return
    end
  elsif broken_action['type'] == 'buy_train'
    if prev_action['type'] == 'pass' && game.active_step.is_a?(Engine::Step::Track)
      # Remove the pass, as it was probably meant for a token
      actions.delete(prev_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::DiscardTrain) && next_action['type'] == 'discard_train'
      switch_actions(original_actions, broken_action, next_action)
      return [broken_action, next_action]
    end
    if game.active_step.is_a?(Engine::Step::Track)
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return
    end
    if game.active_step.is_a?(Engine::Step::Token)
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return
    end
    if game.active_step.is_a?(Engine::Step::BuyCompany) && prev_action['type'] == 'pass'
      actions.delete(prev_action)
      return
    end
  elsif broken_action['type'] == 'run_routes'
    if game.active_step.is_a?(Engine::Step::Dividend) && prev_action['type'] == 'run_routes'
      actions.delete(prev_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::Track)
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return
    end
    if game.active_step.is_a?(Engine::Step::Token)
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return
    end
  elsif broken_action['type']=='place_token' &&
    ['D6-0-3','298-0-2'].include?(broken_action['city']) &&
    game.companies.find { |company| company.name == 'Chicago and Western Indiana' }&.owner == game.active_step.current_entity
    # Move token lay from corp to private
    broken_action['entity'] = 'C&WI'
    broken_action['entity_type'] = 'company'
    return [broken_action]
  elsif game.active_step.is_a?(Engine::Step::Token)
    pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
    actions.insert(action_idx, pass)
    return

  elsif game.active_step.is_a?(Engine::Step::TrackAndToken)
    if ['buy_shares','sell_shares'].include?(broken_action['type']) and prev_action['type'] == 'pass'
      # Stray pass from buy companies
      actions.delete(prev_action)
      return
    end
    pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
    actions.insert(action_idx, pass)
    return
  elsif broken_action['type'] == 'dividend' and broken_action['entity_type'] == 'minor'
    actions.delete(broken_action)
    return
  end

  puts "Game think it's #{game.active_step.current_entity.id} turn"
  raise Exception, "Cannot fix http://18xx.games/game/#{game.id}?action=#{action}"
end

def attempt_repair(actions)
  repairs = []
  rewritten = false
  ever_repaired = false
  loop do
    game = yield
    game.instance_variable_set(:@loading, true)
    # Locate the break
    repaired = false
    filtered_actions, _active_undos = game.class.filtered_actions(actions)
    filtered_actions.compact!

    filtered_actions.each.with_index do |action, _index|
      action = action.copy(game) if action.is_a?(Engine::Action::Base)
      begin
        game.process_action(action)
      rescue Exception => e
        puts "Break at #{e} #{action}"
        ever_repaired = true
        inplace_actions = repair(game, actions, filtered_actions, action)
        repaired = true
        if inplace_actions
          repairs += inplace_actions
        else
          rewritten = true
          # Added or moved actions... destroy undo states and renumber.
          filtered_actions.each_with_index do |a, idx|
            a['original_id'] = a['id'] unless a.include?('original_id')
            a['id'] = idx + 1
          end
          actions = filtered_actions
        end
        break
      end
    end

    break unless repaired
  end
  return actions if ever_repaired
end

def migrate_data(data, fix_one = true)
players = data['players'].map { |p| p['name'] }
  engine = Engine::GAMES_BY_TITLE[data['title']]
  begin
    data['actions'] = attempt_repair(data['actions']) do
      engine.new(
        players,
        id: data['id'],
        actions: [],
      )
    end
  rescue Exception => e
    puts 'Failed to fix :(', e
    return data
  end
  fixed = true
  return data if fixed
end

# This doesn't write to the database
def migrate_db_actions(data, fix_one = false)
  original_actions = data.actions.map(&:to_h)

  engine = Engine::GAMES_BY_TITLE[data.title]
  begin
    actions = attempt_repair(original_actions) do
      engine.new(
        data.ordered_players.map(&:name),
        id: data.id,
        actions: [],
      )
    end
    return actions || original_actions
  rescue Exception => e
    puts 'Something went wrong', e
    #raise e

  end
  return original_actions
end

def migrate_json(filename, fix_one = true)
  data = migrate_data(JSON.parse(File.read(filename)), fix_one)
  if data
    File.write(filename, JSON.pretty_generate(data))
  else
    puts 'Nothing to do, game works'
  end
end

def db_to_json(id, filename)
  game = Game[id]
  json = game.to_h(include_actions: true)
  File.write(filename, JSON.pretty_generate(json))
end

def migrate_db_to_json(id, filename)
  game = Game[id]
  json = game.to_h(include_actions: true)
  json['actions'] = migrate_db_actions(game)
  File.write(filename, JSON.pretty_generate(json))
end
