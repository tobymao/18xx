# frozen_string_literal: true
# rubocop:disable all

# Inserts a `pass` action for the owner of P1 (Banater Montanbahn) wherever the
# new 1880 Romania rule holds their stock-round turn open and the log has no
# action for it (the old code auto-skipped them).
#
# Usage (from the repo root):
#   ruby scripts/migrate_1880_romania_banater_pass.rb dry      # report only
#   ruby scripts/migrate_1880_romania_banater_pass.rb write    # save changes
#   ruby scripts/migrate_1880_romania_banater_pass.rb write 271851 12345
#
# Only games titled '1880' that load as the Romania variant are touched.
# Any failure other than the banater case is reported and the game is left alone.

require_relative 'scripts_helper'

MAX_BANATER_REPAIRS = 50

# Renumber actions after inserting one, mirrors the rewrite path in migrate_auto_actions.rb.
def renumber_banater_actions(actions)
  actions.each_with_index do |action, idx|
    action['id'] = idx + 1
  end
end

# True when the stock-round step is holding this owner's turn open for P1,
# i.e. the fixed BuySellParShares step is offering only `pass`.
def banater_hold?(game, step)
  return false unless step.is_a?(Engine::Game::G1880Romania::Step::BuySellParShares)

  current = step.current_entity
  banater = game.banater
  return false unless current && banater && !banater.closed? && banater.owner == current

  step.actions(current) == %w[pass]
end

# Replays the game and inserts a pass for the P1 owner before any action that
# fails because their turn is being held open. Returns [actions, inserted_count].
# Raises on any other failure so the game is not written.
def repair_banater_passes(data, actions)
  inserted = 0

  MAX_BANATER_REPAIRS.times do
    game = Engine::Game.load(data, actions: []).maybe_raise!
    game.instance_variable_set(:@loading, true)

    filtered, _undos = game.class.filtered_actions(actions)
    filtered.compact!

    broken = nil
    filtered.each do |action|
      action = action.copy(game) if action.is_a?(Engine::Action::Base)
      begin
        game.process_action(action).maybe_raise!
      rescue Exception
        broken = action
        break
      end
    end

    return [actions, inserted] unless broken

    step = game.active_step
    unless banater_hold?(game, step)
      raise "unexpected failure at action #{broken['id']} (#{broken['entity']}, #{broken['type']}): " \
            "not a P1 hold; step #{step&.type}"
    end

    owner = step.current_entity
    idx = filtered.index(broken)
    pass = Engine::Action::Pass.new(owner)
    pass.user = pass.entity.player.id
    filtered.insert(idx, pass.to_h)
    inserted += 1

    renumber_banater_actions(filtered)
    actions = filtered
  end

  raise "stuck after #{MAX_BANATER_REPAIRS} repairs"
end

# Writes the new action list back to the DB, same as the full-rewrite branch
# of migrate_db_actions in migrate_auto_actions.rb.
def rewrite_banater_actions(data, actions)
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

def romania_game?(data)
  Engine::Game.load(data, actions: []).class.to_s.include?('Romania')
rescue Exception
  false
end

def migrate_romania_banater(data, dry_run: true)
  actions = data.actions.map(&:to_h)
  new_actions, inserted = repair_banater_passes(data, actions)

  if inserted.zero?
    puts "Game #{data.id}: no changes"
    return
  end

  puts "Game #{data.id}: inserting #{inserted} pass action(s)"
  return if dry_run

  rewrite_banater_actions(data, new_actions)
  puts "Game #{data.id}: saved"
end

def run_romania_banater_migration(mode = 'dry', game_ids = nil, status: %w[active finished])
  dry_run = mode != 'write'
  where = { title: '1880', status: status }
  where[:id] = game_ids.map(&:to_i) if game_ids && !game_ids.empty?

  DB[:games].order(:id).where(**where).select(:id).paged_each(rows_per_fetch: 1) do |row|
    game = Game.eager(:user, :players, :actions).where(id: [row[:id]]).first
    next unless game && romania_game?(game)

    begin
      migrate_romania_banater(game, dry_run: dry_run)
    rescue Exception => e
      puts "Game #{row[:id]}: skipped (#{e.message})"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  mode = ARGV.shift || 'dry'
  run_romania_banater_migration(mode, ARGV)
end
