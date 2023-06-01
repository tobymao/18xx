# frozen_string_literal: true
# rubocop:disable all

require_relative 'models'

Dir['./models/**/*.rb'].sort.each { |file| require file }

Sequel.extension :pg_json_ops
require_relative 'lib/engine'

$broken = {}

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

# If inserting/deleting actions, modify the given `actions` and return `nil`
#
# If editing existing actions, modify them on `actions` in place, and return an
# array containing the just the modified actions (so the modified actions will
# be in both the originally given `actions` and in the returned array)
def repair(game, original_actions, actions, broken_action, data, pry_db: false)
  optionalish_actions = %w[message buy_company]
  broken_action_idx = actions.index(broken_action)
  action = broken_action['original_id'] || broken_action['id']
  step = game.active_step
  prev_actions = actions[0..broken_action_idx - 1]
  prev_action = prev_actions[prev_actions.rindex { |a| !optionalish_actions.include?(a['type']) }]
  next_actions = actions[broken_action_idx + 1..]
  next_action = next_actions.find { |a| !optionalish_actions.include?(a['type']) }
  current_entity = step.current_entity

  entity_id = broken_action['entity']
  entity = game.corporation_by_id(entity_id) ||
           game.company_by_id(entity_id) ||
           game.player_by_id(entity_id)

  step_actions = step.actions(current_entity)

  ################
  # BEGIN REPAIR #
  ################
  # When a new migration is needed for something more than adding/removing pass
  # actions, delete blocks here for completed migrations and add a new commented
  # block; see the history of this file for examples of previous migrations.

  if pry_db
    require 'pry-byebug'
    binding.pry
  end

  # Generic handling for when a change just needs pass actions to be
  # inserted/deleted

  # action seems ok, try deleting auto_action pass
  if broken_action['entity'] == game.current_entity.id &&
     game.round.actions_for(game.current_entity).include?(broken_action['type']) &&
     (broken_action['auto_actions'] || []).map { |aa| aa['type'] } == ['pass']
     actions[broken_action_idx].delete('auto_actions')
     puts '        patched: removed auto_action pass from broken_action'
     return [actions[broken_action_idx]]
  end

  # fix entity for pass action
  if broken_action['type'] == 'pass' && game.current_entity.id != broken_action['entity']
    entity_type =
      if game.current_entity.company?
        'company'
      else
        broken_action['entity_type']
      end
    puts "        patched: changed entity of broken pass from #{broken_action['entity']} to #{game.current_entity.id} in current_action"
    actions[broken_action_idx]['entity'] = game.current_entity.id
    actions[broken_action_idx]['entity_type'] = entity_type
    return [actions[broken_action_idx]]
  end

  # delete pass from current_action
  if broken_action['type'] == 'pass' && !step_actions.include?('pass')
    actions.delete(broken_action)
    puts '        patched: deleted pass from current_action'
    return
  end

  # delete pass from current_action, move its auto_actions to prev_action
  if broken_action['type'] == 'pass' && broken_action.include?('auto_actions')
    if (auto_actions = broken_action.delete('auto_actions'))
      actions[broken_action_idx - 1]['auto_actions'] = auto_actions
    end
    puts '        patched: deleted pass from current_action, moved auto_actions to pre_action'
    return
  end

  # delete pass from prev_action when the broken_action would have worked in
  # that spot
  if !step_actions.include?(broken_action['type']) &&
        prev_action['type'] == 'pass' &&
        (g = Engine::Game.load(data, actions: prev_actions[..-2]))
          .round
          .actions_for(g.corporation_by_id(broken_action['entity']) || g.company_by_id(broken_action['entity']))
          .include?(broken_action['type'])
    actions.delete(prev_action)
    puts '        patched: deleted pass from prev_action'
    return
  end

  # delete pass from prev_action, move its auto_action pass to the prior action
  if !step_actions.include?(broken_action['type']) &&
        prev_action['type'] == 'pass' &&
        (prev_action['auto_actions'] || []).map { |aa| aa['type'] } == ['pass'] &&
        !actions[broken_action_idx - 2].include?('auto_actions')

    actions[broken_action_idx - 2]['auto_actions'] = prev_action.delete('auto_actions')
    actions.delete(prev_action)
    puts '        patched: deleted pass from prev_action and moved pass auto_action to prior action'
    return
  end

  # insert pass
  if !step_actions.include?(broken_action['type']) && step_actions.include?('pass')
    pass = Engine::Action::Pass.new(current_entity)
    pass.user = pass.entity.player.id
    actions.insert(broken_action_idx, pass.to_h)
    puts '        patched: inserted pass'
    return
  end
  ################
  # END REPAIR #
  ################

  raise Exception, "Cannot fix Game #{game.id} at action #{action}"
end

def attempt_repair(actions, debug, data, pry_db: false)
  repairs = []
  rewritten = false
  ever_repaired = false
  iteration = 0
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
        game.process_action(action).maybe_raise!
      rescue Exception => e
        puts e.backtrace if debug
        iteration += 1
        puts "    iteration #{iteration}; action #{action['id']}; #{game.active_step.type} step; #{action['entity']}, #{action['type']}"

        raise Exception, "Stuck in infinite loop?" if iteration > 100

        ever_repaired = true
        inplace_actions = repair(game, actions, filtered_actions, action, data, pry_db: pry_db)
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

def migrate_data(data, debug=true)
  begin
    data['actions'], repairs = attempt_repair(data['actions'], debug, data) do
      Engine::Game.load(data, actions: []).maybe_raise!
    end
  rescue Exception => e
    puts 'Failed to fix :(', e
    return data
  end

  # running a migration on a game without issues returns nil actions
  return unless data['actions']

  data
end

# This doesn't write to the database
def migrate_db_actions_in_mem(data, debug=false)
  original_actions = data.actions.map(&:to_h)

  begin
    actions, repairs = attempt_repair(original_actions, debug, data) do
      Engine::Game.load(data, actions: []).maybe_raise!
    end
    puts repairs
    return actions || original_actions
  rescue Exception => e
    puts 'Something went wrong', e
    #raise e

  end
  return original_actions
end

def migrate_db_actions(data, pin=nil, dry_run=false, debug=false, pry_db: false, require_pin: false)
  raise Exception, "pin is not valid" if !pin && require_pin

  puts "\nGame #{data.id}"

  original_actions = data.actions.map(&:to_h)
  begin
    actions, repairs = attempt_repair(original_actions, debug, data, pry_db: pry_db) do
      Engine::Game.load(data, actions: []).maybe_raise!
    end
    if actions && !dry_run
      if repairs
        puts '    saving changed actions'
        repairs.each do |action|
          # Find the action index
          idx = actions.index(action)
          data.actions[idx].action = action
          data.actions[idx].save
        end
      else # Full rewrite.
        puts '    game fixed, rewriting all actions'
        DB.transaction do
          Action.where(game: data).delete
          game = Engine::Game.load(data, actions: []).maybe_raise!
          # Set back to loading
          game.instance_variable_set(:@loading, true)
          actions.each do |action|
            game.process_action(action)
            game.maybe_raise!

            Action.create(
              game: data,
              user: action.key?('user') ? User[action['user']] : data.user,
              action_id: game.actions.last.id,
              action: action,
            )
          end
        end
      end
    end
    return actions || original_actions
  rescue Exception => e
    $broken[data.id]=e
    puts e.backtrace if debug
    puts "    #{e}"
    if !dry_run
      if pin == :delete || pin == :archive
        puts "    Archiving #{data.id}"
        data.archive!
      else
        puts "    Would pin #{data.id} to #{pin}"
        data.settings['pin']=pin
        data.save
      end
    else
      puts "    Needs pinning #{data.id} to #{pin}"
    end
  end
  return original_actions
end

def migrate_json(filename, debug=true)
  puts "Loading #{filename} for migration"
  data = migrate_data(JSON.parse(File.read(filename)), debug)
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

# Pass pin=:archive to archive failed games
def migrate_title(title, pin, dry_run=false, debug = false, require_pin: false)
  DB[:games].order(:id).where(Sequel.pg_jsonb_op(:settings).has_key?('pin') => false, status: %w[active finished], title: title).select(:id).paged_each(rows_per_fetch: 1) do |game|
    games = Game.eager(:user, :players, :actions).where(id: [game[:id]]).all
    games.each {|data|
      migrate_db_actions(data, pin, dry_run, debug, require_pin: require_pin)
    }

  end
end

def migrate_all(pin=nil, dry_run=false, debug = false, pry_db: false, game_ids: nil, require_pin: false, status: %w[active finished])
  # can uncomment this for less noise in dev; don't commit it uncommented as
  # that breaks the script in prod
  # DB.loggers.first.level = Logger::FATAL

  where_args = {
    Sequel.pg_jsonb_op(:settings).has_key?('pin') => false,
    status: status,
  }
  where_args[:id] = game_ids if game_ids

  DB[:games].order(:id).where(**where_args).select(:id).paged_each(rows_per_fetch: 1) do |game|
    games = Game.eager(:user, :players, :actions).where(id: [game[:id]]).all
    games.each {|data|
      migrate_db_actions(data, pin, dry_run, debug, pry_db: pry_db, require_pin: require_pin)
    }

  end
end
