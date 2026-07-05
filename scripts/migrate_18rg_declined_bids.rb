# frozen_string_literal: true
# rubocop:disable all

# When invoked directly with a JSON file argument, skip DB requires and load
# only the engine (no sequel/DB available in dev without a running DB server).
if __FILE__ == $0 && ARGV[0]
  require 'json'
  require_relative '../lib/engine'
  Engine::Logger.set_level(Logger::FATAL)
else
  require_relative 'scripts_helper'
end

$broken = {}

# If the same action is repaired more than this many times, the repair is not
# converging (e.g. the fix-entity handler flip-flopping a pass between two
# players). Bail out and pin instead of looping up to the iteration cap.
MAX_REPAIRS_PER_ACTION = 6

def entity_matches_action_entity?(entity, action)
  action['entity'] == entity.id &&
    entity.send(action['entity_type'] + '?')
end

def repair(game, original_actions, actions, broken_action, data, pry_db: false)
  optionalish_actions = %w[message buy_company]
  broken_action_idx = actions.index(broken_action)
  action = broken_action['original_id'] || broken_action['id']
  step = game.active_step

  # Game reached its end condition mid-replay (e.g. the declined-bids fix
  # resolves an earlier auction differently, so the game finishes before all
  # recorded actions are consumed). There is no active step to repair against —
  # bail out with a clear message so the game is pinned, instead of crashing on
  # nil active_step below.
  if step.nil? || game.finished
    remaining = actions.size - broken_action_idx
    raise Exception, "Cannot fix Game #{game.id} — game finished early with #{remaining} action(s) remaining " \
                     "(#{broken_action['type']} from #{broken_action['entity']} at action #{action}), game needs pinning"
  end

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

  if pry_db
    require 'pry-byebug'
    binding.pry
  end

  # 18RoyalGorge: remove pass from player who already declined in
  # SingleItemAuction (PR #12546)
  if broken_action['type'] == 'pass' &&
     step.is_a?(Engine::Game::G18RoyalGorge::Step::SingleItemAuction) &&
     !entity_matches_action_entity?(current_entity, broken_action)

    actions.delete(broken_action)
    puts "        patched: deleted pass from declined player #{broken_action['entity']} (18RG SingleItemAuction)"
    return
  end

  # 18RoyalGorge: an auction bid has ended up outside the SingleItemAuction step
  # (the auction resolved early once declined players are removed from
  # @active_bidders, so the game has moved on to a later step). Inserting a pass
  # cannot fix this — it loops forever — so bail out and let the game be pinned.
  if broken_action['type'] == 'bid' &&
     !step.is_a?(Engine::Game::G18RoyalGorge::Step::SingleItemAuction) &&
     !entity_matches_action_entity?(current_entity, broken_action)

    raise Exception, "Cannot fix Game #{game.id} — orphaned auction bid from #{broken_action['entity']} " \
                     "in #{step.class.name}, game needs pinning"
  end

  # Generic handling for when a change just needs pass actions to be
  # inserted/deleted

  # action seems ok, try deleting auto_action pass
  if entity_matches_action_entity?(game.current_entity, broken_action) &&
     game.round.actions_for(game.current_entity).include?(broken_action['type']) &&
     (broken_action['auto_actions'] || []).map { |aa| aa['type'] } == ['pass']
    actions[broken_action_idx].delete('auto_actions')
    puts '        patched: removed auto_action pass from broken_action'
    return [actions[broken_action_idx]]
  end

  # fix entity for pass action
  if broken_action['type'] == 'pass' && !entity_matches_action_entity?(game.current_entity, broken_action)
    entity_type =
      if game.current_entity.company?
        'company'
      elsif game.current_entity.corporation?
        'corporation'
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
  if (!step_actions.include?(broken_action['type']) && step_actions.include?('pass')) ||
     !entity_matches_action_entity?(current_entity, broken_action)
    pass = Engine::Action::Pass.new(current_entity)
    pass.user = pass.entity.player.id
    actions.insert(broken_action_idx, pass.to_h)
    puts '        patched: inserted pass'
    return
  end
  ################
  # END REPAIR   #
  ################

  raise Exception, "Cannot fix Game #{game.id} at action #{action}"
end

def attempt_repair(actions, debug, data, pry_db: false)
  repairs = []
  rewritten = false
  ever_repaired = false
  iteration = 0
  repair_counts = Hash.new(0)
  loop do
    game = yield
    game.instance_variable_set(:@loading, true)
    repaired = false
    filtered_actions, _active_undos = game.class.filtered_actions(actions)
    filtered_actions.compact!

    filtered_actions.each_with_index do |action, _index|
      action = action.copy(game) if action.is_a?(Engine::Action::Base)
      begin
        game.process_action(action).maybe_raise!
      rescue Exception => e
        puts e.backtrace if debug
        iteration += 1
        puts "    iteration #{iteration}; action #{action['id']}; #{game.active_step&.type || 'none (game over)'} step; #{action['entity']}, #{action['type']}"

        raise Exception, "Stuck in infinite loop?" if iteration > 100

        # Detect a non-converging repair: the same action keeps getting repaired
        # without the replay ever moving past it (the auction fix cascades into
        # the stock round and the fix-entity handler flip-flops a pass between
        # players). Bail out so the game is pinned instead of looping.
        repair_key = action['original_id'] || action['id']
        repair_counts[repair_key] += 1
        if repair_counts[repair_key] > MAX_REPAIRS_PER_ACTION
          raise Exception, "Cannot fix Game #{game.id} — non-converging repair at action #{repair_key} " \
                           "(#{action['type']} from #{action['entity']} repaired #{repair_counts[repair_key]} times), game needs pinning"
        end

        ever_repaired = true
        inplace_actions = repair(game, actions, filtered_actions, action, data, pry_db: pry_db)
        repaired = true
        if inplace_actions
          repairs += inplace_actions
        else
          rewritten = true
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

  return unless data['actions']

  data
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
          idx = actions.index(action)
          data.actions[idx].action = action
          data.actions[idx].save
        end
      else
        puts '    game fixed, rewriting all actions'
        DB.transaction do
          Action.where(game: data).delete
          game = Engine::Game.load(data, actions: []).maybe_raise!
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
    $broken[data.id] = e
    puts e.backtrace if debug
    puts "    #{e}"
    if !dry_run
      if pin == :delete || pin == :archive
        puts "    Archiving #{data.id}"
        data.archive!
      else
        if pin
          puts "    Pinning #{data.id} to #{pin}"
          data.settings['pin'] = pin
          data.save
        else
          puts "    Skipping pin (none given)"
        end
      end
    else
      puts "    Needs pinning #{data.id} to #{pin}"
    end
  end
  return original_actions
end

# Pass pin=:archive to archive failed games
def migrate_title(title='18RoyalGorge', pin=nil, dry_run=false, debug=false, require_pin: false)
  DB[:games].order(:id).where(Sequel.pg_jsonb_op(:settings).has_key?('pin') => false, status: %w[active finished], title: title).select(:id).paged_each(rows_per_fetch: 1) do |game|
    games = Game.eager(:user, :players, :actions).where(id: [game[:id]]).all
    games.each { |data| migrate_db_actions(data, pin, dry_run, debug, require_pin: require_pin) }
  end
end

# JSON test: ruby scripts/migrate_18rg_declined_bids.rb tmp/253839.json
if __FILE__ == $0 && ARGV[0]
  migrate_json(ARGV[0])
end
