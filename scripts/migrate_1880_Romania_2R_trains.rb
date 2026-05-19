# frozen_string_literal: true

require_relative 'scripts_helper'

TRAIN_MAP_1880_ROMANIA = {
  '2R-0' => '2P-0',
  '2R-1' => '2P-1',
  '2R-2' => '2P-2',
  '2R-3' => '2P-3',
  '2R-4' => '2P-4',
  '2R-5' => '2P-5',
  '2R-6' => '2P-6',
  '2R-7' => '2P-7',
  '2R-8' => '2P-8',
  '2R-9' => '2P-9',
}.freeze

VARIANT_MAP_1880_ROMANIA = {
  '2R' => '2P',
}.freeze

def migrate_1880_romania_trains(dry_run: true)
  ids = game_ids_1880_romania
  Game.eager(:actions).where(id: ids).all.each do |game|
    migrate_single_game_1880(game, dry_run)
  end
  nil
end

def migrate_single_game_1880(game, dry_run)
  DB.transaction do
    game.actions.each do |action|
      updated = migrate_train(action[:action], TRAIN_MAP_1880_ROMANIA, VARIANT_MAP_1880_ROMANIA)
      action.save if updated && !dry_run
    end
    Engine::Game.load(game).maybe_raise!
    msg = "Game #{game.id} [#{game.title}]: successfully validated"
    unless dry_run
      game.save
      msg += ' and saved'
    end
    puts msg
  rescue StandardError => e
    puts "Game #{game.id} [#{game.title}]: failed validation #{e}"
    raise Sequel::Rollback
  end
end

def game_ids_1880_romania
  Game.where(
    title: '1880 Romania',
    status: %w[active finished],
    Sequel.pg_jsonb_op(:settings).has_key?('pin') => false
  ).select_map(:id)
end

def migrate_train(action, tmap, vmap)
  updated = false
  if action.key?('routes')
    action['routes'].each do |route|
      updated |= migrate_train(route, tmap, vmap)
    end
  end
  if tmap.key?(action['train'])
    action['train'] = tmap[action['train']]
    updated = true
  end
  if tmap.key?(action['exchange'])
    action['exchange'] = tmap[action['exchange']]
    updated = true
  end
  if vmap.key?(action['variant'])
    action['variant'] = vmap[action['variant']]
    updated = true
  end
  updated
end