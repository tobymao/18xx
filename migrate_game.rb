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
def repair(game, original_actions, actions, broken_action, data)
  optionalish_actions = %w[message buy_company]
  broken_action_idx = actions.index(broken_action)
  action = broken_action['original_id'] || broken_action['id']
  puts "http://18xx.games/game/#{game.id}?action=#{action}"
  step = game.active_step
  puts step
  prev_actions = actions[0..broken_action_idx - 1]
  prev_action = prev_actions[prev_actions.rindex { |a| !optionalish_actions.include?(a['type']) }]
  next_actions = actions[broken_action_idx + 1..]
  next_action = next_actions.find { |a| !optionalish_actions.include?(a['type']) }
  puts broken_action
  current_entity = step.current_entity
  puts "Game think it's #{current_entity.id}'s turn"

  entity_id = broken_action['entity']
  entity = game.corporation_by_id(entity_id) ||
           game.company_by_id(entity_id) ||
           game.player_by_id(entity_id)

  ################
  # BEGIN REPAIR #
  ################
  # When a new migration is needed for something more than adding/removing pass
  # actions, delete blocks here for completed migrations and add a new commented
  # block; see the history of this file for examples of previous migrations.

  # uncomment the following lines for debugging
  # require 'pry-byebug'
  # binding.pry

  # Issue #7863 -- implicit use of P5-LC&DR to token in English Channel needs to
  # become explicit
  if broken_action['type'] == 'place_token' &&
     entity == game.company_by_id('P5').owner &&
     broken_action['tokener'] == broken_action['entity'] &&
     broken_action['entity_type'] == 'corporation' &&
     %w[X4 X9 X15].include?(broken_action['city'].split('-').first)
    # update current broken action
    broken_action['entity'] = 'P5'
    broken_action['entity_type'] = 'company'
    return [broken_action]
  end
  # in most cases, the broken action comes much later than when the English
  # Channel token was laid, so search back through the actions to find when it
  # was laid and change that action
  game.actions.each do |a|
    next unless a.type  == 'place_token'
    next unless a.to_h['entity_type']  == 'corporation'
    next unless a.entity == a.instance_variable_get(:@tokener)
    next unless a.token.city&.hex&.id == 'P43'
    index = a.id - 1
    actions_ = actions.slice(0, index)
    g = Engine::Game.load(data, actions: actions_)
    if g.current_entity == g.company_by_id('P5').owner
      # update English Channel token action in the past
      actions[index]['entity'] = 'P5'
      actions[index]['entity_type'] = 'company'
      return [actions[index]]
    end
  end
  # /end Issue #7863

  # Keep this block if possible; insert/delete passes as necessary for generic
  # migration fixes
  #
  # 1) pass is broken, maybe deleting it works
  # 2) broken action doesn't work with current step, but does on prev step where
  #    a pass was used, maybe deleting that pass works
  # 3) current step rejects the broken action but likes pass, maybe inserting
  # pass works
  step_actions = step.actions(current_entity)
  if broken_action['type'] == 'pass' && !step_actions.include?('pass')
    actions.delete(broken_action)
    return
  elsif !step_actions.include?(broken_action['type']) &&
        prev_action['type'] == 'pass' &&
        Engine::Game.load(data, actions: prev_actions).active_step
          .actions(current_entity).include?(broken_action['type'])
    actions.delete(prev_action)
    return
  elsif !step_actions.include?(broken_action['type']) && step_actions.include?('pass')
    pass = Engine::Action::Pass.new(current_entity)
    pass.user = pass.entity.player.id
    actions.insert(broken_action_idx, pass.to_h)
    return
  end
  ################
  # END REPAIR #
  ################

  raise Exception, "Cannot fix http://18xx.games/game/#{game.id}?action=#{action}"
end

def attempt_repair(actions, debug, data)
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
        puts "Break at #{e} #{action} #{iteration}"
        raise Exception, "Stuck in infinite loop?" if iteration > 100

        ever_repaired = true
        inplace_actions = repair(game, actions, filtered_actions, action, data)
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

def migrate_db_actions(data, pin, dry_run=false, debug=false)
  raise Exception, "pin is not valid" unless pin

  original_actions = data.actions.map(&:to_h)
  begin
    actions, repairs = attempt_repair(original_actions, debug, data) do
      Engine::Game.load(data, actions: []).maybe_raise!
    end
    if actions && !dry_run
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
    puts 'Something went wrong', e
    if !dry_run
      if pin == :delete || pin == :archive
        puts "Archiving #{data.id}"
        data.archive!
      else
        puts "Pinning #{data.id} to #{pin}"
        data.settings['pin']=pin
        data.save
      end
    else
      puts "Needs pinning #{data.id} to #{pin}"
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
def migrate_title(title, pin, dry_run=false, debug = false)
  DB[:games].order(:id).where(Sequel.pg_jsonb_op(:settings).has_key?('pin') => false, status: %w[active finished], title: title).select(:id).paged_each(rows_per_fetch: 1) do |game|
    games = Game.eager(:user, :players, :actions).where(id: [game[:id]]).all
    games.each {|data|
      migrate_db_actions(data, pin, dry_run, debug)
    }

  end
end

def migrate_all(pin, dry_run=false, debug = false, game_ids: nil)
  where_args = {
    Sequel.pg_jsonb_op(:settings).has_key?('pin') => false,
    status: %w[active finished],
  }
  where_args[:id] = game_ids if game_ids

  DB[:games].order(:id).where(**where_args).select(:id).paged_each(rows_per_fetch: 1) do |game|
    games = Game.eager(:user, :players, :actions).where(id: [game[:id]]).all
    games.each {|data|
      migrate_db_actions(data, pin, dry_run, debug)
    }

  end
end
