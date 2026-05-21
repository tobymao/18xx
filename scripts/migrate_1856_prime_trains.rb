# frozen_string_literal: true

require_relative 'scripts_helper'

TRAIN_MAP_1856 = {
  '2\'-0' => '2-5',
  '3\'-0' => '3-4',
  '4\'-0' => '4-3',
  '5\'-0' => '5-2',
}.freeze

TRAIN_MAP_1836JR = {
  '2\'-0' => '2-4',
  '3\'-0' => '3-3',
  '4\'-0' => '4-2',
  '5\'-0' => '5-1',
}.freeze

VARIANT_MAP = {
  '2\'' => '2',
  '3\'' => '3',
  '4\'' => '4',
  '5\'' => '5',
}.freeze

def migrate_prime_trains(dry_run: true)
  ids = game_ids
  Game.eager(:actions).where(id: ids).all.each do |game|
    migrate_single_game(game, dry_run)
  end
  nil
end

def migrate_single_game(game, dry_run)
  tmap, vmap =
    if game.title == '1856'
      [TRAIN_MAP_1856, VARIANT_MAP]
    else
      [TRAIN_MAP_1836JR, VARIANT_MAP]
    end

  DB.transaction do
    game.actions.each do |action|
      updated = migrate_train(action[:action], tmap, vmap)
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

def game_ids
  # rubocop:disable Style/HashSyntax, Style/PreferredHashMethods
  Game.where(
    title: %w[1856 1836Jr56],
    status: %w[active finished],
    Sequel.pg_jsonb_op(:settings).has_key?('pin') => false
  ).select_map(:id)
  # rubocop:enable Style/HashSyntax, Style/PreferredHashMethods
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
