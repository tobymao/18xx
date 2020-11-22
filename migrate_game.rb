# frozen_string_literal: true
# rubocop:disable all

require_relative 'models'

Dir['./models/**/*.rb'].sort.each { |file| require file }
Sequel.extension :pg_json_ops
require_relative 'lib/engine'

def switch_actions(actions, first, second)
  first_idx = actions.index(first)
  second_idx = actions.index(second)

  id = second['id']
  second['id'] = first['id']
  first['id'] = id

  actions[first_idx] = second
  actions[second_idx] = first
  return [first, second]
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
  puts broken_action
  if broken_action['type'] == 'move_token'
    # Move token is now place token.
    broken_action['type'] = 'place_token'
    return [broken_action]
  elsif game.active_step.is_a?(Engine::Step::G1817::Acquire)
    pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
    actions.insert(action_idx, pass)
    return
  elsif game.active_step.is_a?(Engine::Step::G1889::SpecialTrack)
    # laying track for Ehime Railway didn't always block, now it needs an
    # explicit pass
    if broken_action['entity'] != 'ER'
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return
    end
  elsif broken_action['type'] == 'pass'
    if game.active_step.is_a?(Engine::Step::Route) || game.active_step.is_a?(Engine::Step::BuyTrain)
      # Lay token sometimes needed pass when it shouldn't have
      actions.delete(broken_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::Track)
      # some games of 1889 didn't skip buy train
      actions.delete(broken_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::BuySellParShares)
      # some games of 1889 didn't skip the buy companies step correctly
      actions.delete(broken_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::IssueShares)
      # some 1846 pass too much
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
    if game.active_step.is_a?(Engine::Step::BuyTrain) && game.active_step.actions(game.active_step.current_entity).include?('pass')
      pass = Engine::Action::Pass.new(game.active_step.current_entity).to_h
      actions.insert(action_idx, pass)
      return
    end
    if game.active_step.is_a?(Engine::Step::IssueShares)
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
      return switch_actions(original_actions, broken_action, next_action)
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
  elsif game.active_step.is_a?(Engine::Step::IssueShares) && broken_action['type']=='buy_company'
    # Stray pass from buy trains
    actions.delete(prev_action)
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
        puts e.backtrace
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
  repairs = nil if rewritten
  return [actions, repairs] if ever_repaired
end

def migrate_data(data)
players = data['players'].map { |p| [p['id'],p['name']] }.to_h
  engine = Engine::GAMES_BY_TITLE[data['title']]
  begin
    data['actions'], repairs = attempt_repair(data['actions']) do
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
def migrate_db_actions_in_mem(data)
  original_actions = data.actions.map(&:to_h)

  engine = Engine::GAMES_BY_TITLE[data.title]
  begin
    actions, repairs = attempt_repair(original_actions) do
      engine.new(
        data.ordered_players.map { |u| [u.id, u.name] }.to_h,
        id: data.id,
        actions: [],
        optional_rules: data.settings['optional_rules']&.map(&:to_sym),
      )
    end
    puts repairs
    return actions || original_actions
  rescue Exception => e
    puts 'Something went wrong', e
    #raise e

  end
  return original_actions
end

def migrate_db_actions(data)
  original_actions = data.actions.map(&:to_h)
  engine = Engine::GAMES_BY_TITLE[data.title]
  begin
    actions, repairs = attempt_repair(original_actions) do
      players = data.ordered_players.map { |u| [u.id, u.name] }.to_h
      engine.new(
        players,
        id: data.id,
        actions: [],
        optional_rules: data.settings['optional_rules']&.map(&:to_sym),
      )
    end
    if actions
      if repairs
        repairs.each do |action|
          # Find the action index
          idx = actions.index(action)
          data.actions[idx].action = action
          data.actions[idx].save
        end
      else # Full rewrite.
        DB.transaction do
          Action.where(game: data).delete
          game = engine.new(
            data.ordered_players.map { |u| [u.id, u.name] }.to_h,
            id: data.id,
            actions: [],
            optional_rules: data.settings['optional_rules']&.map(&:to_sym),
          )
          actions.each do |action|
            game.process_action(action)
            Action.create(
              game: data,
              user: data.user,
              action_id: game.actions.last.id,
              turn: game.turn,
              round: game.round.name,
              action: action,
            )
          end
        end
      end
    end
    return actions || original_actions
  rescue Exception => e
    puts 'Something went wrong', e
    puts "Pinning #{data.id}"
    pin = '5f8239fb'
    data.settings['pin']=pin
    data.save
  end
  return original_actions
end

def migrate_json(filename)
  data = migrate_data(JSON.parse(File.read(filename)))
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

def migrate_title(title)
  DB[:games].order(:id).where(Sequel.pg_jsonb_op(:settings).has_key?('pin') => false, status: %w[active finished], title: title).select(:id).paged_each(rows_per_fetch: 1) do |game|
    games = Game.eager(:user, :players, :actions).where(id: [game[:id]]).all
    games.each {|data|
      migrate_db_actions(data)
    }

  end
end

def migrate_all(game_ids: nil)
  where_args = {
    Sequel.pg_jsonb_op(:settings).has_key?('pin') => false,
    status: %w[active finished],
  }
  where_args[:id] = game_ids if game_ids

  DB[:games].order(:id).where(**where_args).select(:id).paged_each(rows_per_fetch: 1) do |game|
    games = Game.eager(:user, :players, :actions).where(id: [game[:id]]).all
    games.each {|data|
      migrate_db_actions(data)
    }

  end
end
