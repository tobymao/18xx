# frozen_string_literal: true
# rubocop:disable all

Dir['./models/**/*.rb'].sort.each { |file| require file }
require './lib/engine'
Sequel.extension :pg_json_ops
DB.extension :pg_array, :pg_advisory_lock, :pg_json, :pg_enum

game_ids = Game.where(status: 'finished').select_map(:id)

game_ids.each_slice(10).each do |ids|
  Game.eager(:user, :players, :actions).where(id: ids).all.each do |game|
    actions = game.actions.map { |a| [a.action_id, a] }.to_h
    engine = Engine::Game.load(game, at_action: 0)
    filtered_actions, _ = engine.class.filtered_actions(actions.values.map(&:to_h))

    new_actions = filtered_actions.compact.map.with_index do |action_h, index|
      old_id = action_h['id']
      new_id = index + 1
      action_h['id'] = new_id
      action = actions.delete(old_id)
      action.action_id = new_id
      action.action = action_h
      action
    end

    next if actions.empty?

    DB.transaction do
      actions.values.each(&:delete)
      new_actions.each(&:save)
    end
  end
end
