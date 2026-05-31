# frozen_string_literal: true
# rubocop:disable all

require 'set'
require_relative 'scripts_helper'

# Migrates pre-#12579 18ESP saves to include explicit destination_connection
# actions/auto_actions. The legacy bridge that applied them at load-time has
# been removed; this script bakes them into the action log permanently.
#
# Two insertion points mirror the original trigger sites:
#   1. Nested auto_action on lay_tile / place_token — the entity just connected
#      its own destination (Track step logic).
#   2. Standalone destination_connection action — connection was established by
#      an earlier action from a different entity and is detected at OR-start
#      (CheckDestinationConnection step logic).
#
# Test against the pre-migration fixture:
#   ruby scripts/migrate_18esp_destination_connection.rb \
#     public/fixtures/18ESP/18ESP_game_end_second_eight.json
#   # => creates public/fixtures/18ESP/18ESP_game_end_second_eight_migrated.json

TILE_ACTIONS = %w[lay_tile place_token].freeze

def dc_auto_action_hash(entity_id)
  {
    'type'         => 'destination_connection',
    'entity'       => entity_id,
    'entity_type'  => 'corporation',
    'corporations' => [entity_id],
  }
end

def dc_standalone_action_hash(entity_id, id, user_id)
  {
    'type'         => 'destination_connection',
    'entity'       => entity_id,
    'entity_type'  => 'corporation',
    'id'           => id,
    'user'         => user_id,
    'corporations' => [entity_id],
  }
end

def check_connection_as_strict?(game, entity)
  return false unless entity&.corporation?
  return false unless entity.destination
  return false if entity.destination_connected?

  game.instance_variable_set(:@loading, false)
  result = game.check_for_destination_connection(entity)
  game.instance_variable_set(:@loading, true)
  result
end

def already_migrated?(data)
  (data['actions'] || []).any? do |a|
    next false unless a

    a['type'] == 'destination_connection' ||
      a['auto_actions']&.any? { |sub| sub&.dig('type') == 'destination_connection' }
  end
end

def renumber_actions(actions)
  id_map = {}
  actions.each_with_index do |a, i|
    id_map[a['id']] = i + 1 if a['id']
    a['id'] = i + 1
  end
  actions.each do |a|
    next unless a.key?('action_id') && id_map.key?(a['action_id'])

    a['action_id'] = id_map[a['action_id']]
  end
end

def inject_destination_connections(data)
  return nil if already_migrated?(data)

  game = Engine::Game.load(data, actions: [], strict: false)
  game.instance_variable_set(:@loading, true)

  default_user     = data.dig('players', 0, 'id')
  filtered_actions, = game.class.filtered_actions(data['actions'] || [])
  filtered_actions.compact!

  result           = []
  dc_count         = 0
  prev_entity      = nil
  pending_dc_corps = Set.new

  filtered_actions.each_with_index do |action_hash, idx|
    entity_id = action_hash['entity']
    entity    = game.corporation_by_id(entity_id)
    new_turn  = (entity_id != prev_entity)

    # OR-start check: only on the first action of each OR turn. For cross-corp
    # connections (pending_dc_corps) the detection happened post-tile; emit
    # standalone now. For others, check_connection_as_strict? with the live graph.
    if new_turn && game.round.is_a?(Engine::Round::Operating)
      if pending_dc_corps.include?(entity_id)
        user_id = entity.owner&.id || default_user
        result << dc_standalone_action_hash(entity_id, result.length + 1, user_id)
        entity.goal_reached!(:destination)
        pending_dc_corps.delete(entity_id)
        dc_count += 1
        puts "  #{entity_id}: standalone OR-start cross-corp (before action #{action_hash['id']})"
      elsif check_connection_as_strict?(game, entity)
        user_id = entity.owner&.id || default_user
        result << dc_standalone_action_hash(entity_id, result.length + 1, user_id)
        entity.goal_reached!(:destination)
        dc_count += 1
        puts "  #{entity_id}: standalone OR-start (before action #{action_hash['id']})"
      end
    end

    game.process_action(action_hash)

    # Force graph recomputation after every action.
    game.instance_variable_get(:@no_blocking_graph)&.clear
    game.instance_variable_get(:@graph)&.clear

    # Post-action check for own-connection via tile lay or token placement.
    if TILE_ACTIONS.include?(action_hash['type'])
      if check_connection_as_strict?(game, entity)
        # Look-ahead: if the very next action is a place_token from the same
        # entity, emit DC as a standalone action BETWEEN the two rather than as
        # an auto_action.  An auto_action DC triggers skip_steps via a stale
        # graph cache which hides the newly-freed token, causing Track to mark
        # itself passed and blocking the subsequent place_token.
        next_action = filtered_actions[idx + 1]

        if next_action && next_action['type'] == 'place_token' && next_action['entity'] == entity_id
          user_id = entity.owner&.id || default_user
          entity.goal_reached!(:destination)
          dc_count += 1
          puts "  #{entity_id}: standalone mid-turn (between #{action_hash['id']} and #{next_action['id']})"

          # Cross-corp check still runs before we bail out of the normal path.
          game.corporations.each do |corp|
            next if corp == entity
            next if corp.destination_connected?
            next if pending_dc_corps.include?(corp.id)
            next unless check_connection_as_strict?(game, corp)

            pending_dc_corps.add(corp.id)
            puts "  #{corp.id}: cross-corp pending (#{entity_id} #{action_hash['type']} #{action_hash['id']})"
          end

          result << action_hash
          result << dc_standalone_action_hash(entity_id, result.length + 1, user_id)
          prev_entity = entity_id
          next
        else
          action_hash['auto_actions'] ||= []
          # DC must be first so CDC processes it before any pass auto_action.
          action_hash['auto_actions'].unshift(dc_auto_action_hash(entity_id))
          entity.goal_reached!(:destination)
          dc_count += 1
          puts "  #{entity_id}: nested auto_action on #{action_hash['type']} #{action_hash['id']}"
        end
      end

      # Cross-corp: another corp's destination may now be reachable.
      game.corporations.each do |corp|
        next if corp == entity
        next if corp.destination_connected?
        next if pending_dc_corps.include?(corp.id)
        next unless check_connection_as_strict?(game, corp)

        pending_dc_corps.add(corp.id)
        puts "  #{corp.id}: cross-corp pending (#{entity_id} #{action_hash['type']} #{action_hash['id']})"
      end
    end

    result << action_hash
    prev_entity = entity_id
  end

  return nil if dc_count.zero?

  puts "  #{dc_count} destination_connection(s) inserted"

  renumber_actions(result)

  data.merge('actions' => result)
end

def inject_via_strict_replay!(data)
  max_iterations = 30
  dc_count       = 0

  max_iterations.times do |i|
    trial = JSON.parse(JSON.generate(data))
    game  = Engine::Game.load(trial, strict: true)
    break unless game.exception
    break unless game.exception.message.include?('Check destination connection')

    # game.actions.length is inflated by auto_actions (e.g. program_buy_shares)
    # and does not map 1:1 to data['actions'] indices. Derive the true fail
    # position from the last successfully processed action's sequential ID.
    last_id  = game.actions.filter_map { |a| a.id if a.respond_to?(:id) && a.id }.max || 0
    fail_idx = data['actions'].index { |a| a['id'] == last_id + 1 }

    unless fail_idx
      puts "  WARN: cannot locate action id #{last_id + 1}, aborting"
      break
    end

    fail_action = data['actions'][fail_idx]
    entity_id   = fail_action['entity']
    user_id     = fail_action['user'] || data.dig('players', 0, 'id')

    data['actions'].insert(fail_idx, dc_standalone_action_hash(entity_id, fail_idx + 1, user_id))
    renumber_actions(data['actions'])

    dc_count += 1
    puts "  #{entity_id}: iter #{i + 1} standalone before action #{fail_action['id']}"
  end

  dc_count
end

def validate_migration(migrated_data)
  puts '  Validating (strict: true)...'
  trial = JSON.parse(JSON.generate(migrated_data))
  game  = Engine::Game.load(trial, strict: true)
  if game.exception
    last_id   = game.actions.filter_map { |a| a.id if a.respond_to?(:id) && a.id }.max || 0
    fail_idx  = migrated_data['actions'].index { |a| a['id'] == last_id + 1 }
    fail_action = fail_idx ? migrated_data['actions'][fail_idx] : nil
    puts "  FAIL: #{game.exception.message}"
    puts "  Failed before action id=#{last_id + 1}, entity=#{fail_action&.dig('entity')}, type=#{fail_action&.dig('type')}"
    return false
  end
  dc_goals = game.log.count { |e| e.message.to_s.include?('reached destination goal') }
  puts "  OK — #{dc_goals} destination goal(s) logged"
  true
end

def migrate_data(data)
  migrated = inject_destination_connections(data)
  return nil unless migrated

  extra = inject_via_strict_replay!(migrated)
  puts "  #{extra} additional connection(s) found via strict replay" if extra.positive?

  validate_migration(migrated) ? migrated : nil
end

def migrate_json(filename)
  puts "migrate_json: #{filename}"
  data     = JSON.parse(File.read(filename))
  migrated = migrate_data(data)

  unless migrated
    puts '  Nothing to do or validation failed'
    return
  end

  outfile = filename.sub(/\.json$/, '_migrated.json')
  File.write(outfile, JSON.generate(migrated))
  puts "  Written: #{outfile}"
end

def migrate_db_actions(game_record, dry_run: false)
  puts "\nGame #{game_record.id}"
  data     = JSON.parse(JSON.generate(game_record.to_h(include_actions: true)))
  migrated = migrate_data(data)

  unless migrated
    puts '  Skipping'
    return
  end

  if dry_run
    puts '  dry_run — not writing'
    return
  end

  DB.transaction do
    Action.where(game: game_record).delete
    migrated['actions'].each do |action|
      Action.create(
        game:      game_record,
        user:      action.key?('user') ? User[action['user']] : game_record.user,
        action_id: action['id'],
        action:    action,
      )
    end
  end
  puts '  Saved'
end

def migrate_title(title, dry_run: false)
  DB[:games]
    .order(:id)
    .where(
      Sequel.pg_jsonb_op(:settings).has_key?('pin') => false,
      status: %w[active finished],
      title:  title,
    )
    .select(:id)
    .paged_each(rows_per_fetch: 1) do |row|
      games = Game.eager(:user, :players, :actions).where(id: [row[:id]]).all
      games.each { |g| migrate_db_actions(g, dry_run: dry_run) }
    end
end

ARGV.each { |f| migrate_json(f) } unless ARGV.empty?
