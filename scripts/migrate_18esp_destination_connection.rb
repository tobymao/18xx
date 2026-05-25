# frozen_string_literal: true
# rubocop:disable all

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
#   git show HEAD~2:public/fixtures/18ESP/18ESP_game_end_second_eight.json \
#     > /tmp/original_18esp.json
#   ruby scripts/migrate_18esp_destination_connection.rb
#   # => creates /tmp/original_18esp_migrated.json

def dc_auto_action_hash(entity)
  {
    'type'         => 'destination_connection',
    'entity'       => entity.id,
    'entity_type'  => 'corporation',
    'corporations' => [entity.id],
  }
end

def dc_standalone_action_hash(entity, id, user_id)
  {
    'type'         => 'destination_connection',
    'entity'       => entity.id,
    'entity_type'  => 'corporation',
    'id'           => id,
    'user'         => user_id,
    'corporations' => [entity.id],
  }
end

def already_migrated?(data)
  (data['actions'] || []).any? do |a|
    next false unless a

    a['type'] == 'destination_connection' ||
      Array(a['auto_actions']).any? { |sub| sub&.dig('type') == 'destination_connection' }
  end
end

def inject_destination_connections(data)
  return nil if already_migrated?(data)

  game = Engine::Game.load(data, actions: [], strict: false)
  game.instance_variable_set(:@loading, true)

  default_user     = data.dig('players', 0, 'id')
  filtered_actions, = game.class.filtered_actions(data['actions'] || [])
  filtered_actions.compact!

  result   = []
  dc_count = 0

  filtered_actions.each do |action_hash|
    entity_id = action_hash['entity']
    entity    = game.corporation_by_id(entity_id)

    # OR-start check (CheckDestinationConnection step): if a corporation is about
    # to take its first action in an operating turn and its destination route is
    # already reachable (connected by a prior action from another entity), insert
    # a standalone destination_connection action before it acts.
    if game.round.is_a?(Engine::Round::Operating) &&
       entity&.corporation? &&
       entity.destination &&
       !entity.destination_connected? &&
       game.check_for_destination_connection(entity)

      user_id = entity.owner&.id || default_user
      result << dc_standalone_action_hash(entity, result.length + 1, user_id)
      entity.goal_reached!(:destination)
      dc_count += 1
      puts "  #{entity.id}: standalone OR-start (before action #{action_hash['id']})"
    end

    game.process_action(action_hash)

    # Force recomputation of the no-blocking graph after every action so the
    # next check always sees the current board state.
    game.instance_variable_get(:@no_blocking_graph)&.clear

    # Post-lay / post-token check (Track step): if the entity just laid a tile or
    # placed a token that completed its own destination connection, add a nested
    # auto_action to the triggering action.
    if %w[lay_tile place_token].include?(action_hash['type']) &&
       entity&.corporation? &&
       entity.destination &&
       !entity.destination_connected? &&
       game.check_for_destination_connection(entity)

      action_hash['auto_actions'] ||= []
      action_hash['auto_actions'] << dc_auto_action_hash(entity)
      entity.goal_reached!(:destination)
      dc_count += 1
      puts "  #{entity.id}: nested auto_action on #{action_hash['type']} #{action_hash['id']}"
    end

    result << action_hash
  end

  return nil if dc_count.zero?

  puts "  #{dc_count} destination_connection(s) inserted"

  # Renumber all action IDs sequentially; remap action_id refs in undo entries.
  id_map = {}
  result.each_with_index do |a, i|
    id_map[a['id']] = i + 1 if a['id']
    a['id'] = i + 1
  end
  result.each do |a|
    next unless a.key?('action_id') && id_map.key?(a['action_id'])

    a['action_id'] = id_map[a['action_id']]
  end

  data.merge('actions' => result)
end

def validate_migration(migrated_data)
  puts '  Validating (strict: true)...'
  game = Engine::Game.load(migrated_data, strict: true)
  if game.exception
    puts "  FAIL: #{game.exception}"
    return false
  end
  dc_goals = game.log.to_a.count { |e| e.message.to_s.include?('reached destination goal') }
  puts "  OK — #{dc_goals} destination goal(s) logged"
  true
end

def migrate_data(data)
  migrated = inject_destination_connections(data)
  return nil unless migrated

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
    g = Engine::Game.load(migrated, actions: []).maybe_raise!
    g.instance_variable_set(:@loading, true)
    migrated['actions'].each do |action|
      g.process_action(action)
      g.maybe_raise!
      Action.create(
        game:      game_record,
        user:      action.key?('user') ? User[action['user']] : game_record.user,
        action_id: g.actions.last.id,
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
