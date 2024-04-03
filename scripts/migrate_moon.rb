# frozen_string_literal: true
# rubocop:disable all
require_relative 'scripts_helper'

$failed = []

def fix_action(action, corp_map)
  this_updated = nil

  if (corporation = action["corporation"]) && corp_map[corporation]
    this_updated = true
    action["corporation"] = corp_map[corporation]
  end

  if (tokener = action["tokener"]) && corp_map[tokener]
    this_updated = true
    action["tokener"] = corp_map[tokener]
  end

  if (choice = action["choice"]) && corp_map[choice]
    this_updated = true
    action["choice"] = corp_map[choice]
  end

  if (entity = action["entity"]) && action["entity_type"] == "corporation" && corp_map[entity]
    this_updated = true
    action["entity"] = corp_map[entity]
  end

  if action["shares"]
    action["shares"] = action["shares"].map do |share|
      corp, num = share.split('_')
      if corp_map[corp]
        this_updated = true
        "#{corp_map[corp]}_#{num}"
      else
        share
      end
    end
  end
  this_updated
end

def migrate_db_actions(game)
  corp_map = { "ME" => "SWP",
              "MA" => "HMQ",
              "DSE" => "VH",
              "SM" => "ITC",
              "MV" => "SSF",
              "IPI" => "LG",
              "LP" => "KR" }

  game.actions.each do |a|
    #puts "OLD: #{a.id} a.action: #{a.action}"
    updated = fix_action(a.action, corp_map)
    if (auto = a.action["auto_actions"])
      auto.each do |aa|
        updated = true if fix_action(aa, corp_map)
      end
    end
    #puts "NEW: a.action: #{a.action}" if updated
    a.save if updated
  end
end

def migrate_one(id)
  DB[:games].order(:id).where(id: id).select(:id).paged_each(rows_per_fetch: 1) do |game|
    games = Game.eager(:user, :players).where(id: [game[:id]]).all
    games.each {|game|
      migrate_db_actions(game)
    }
  end
end

def migrate_all()
  DB[:games].order(Sequel.desc(:id)).where(Sequel.pg_jsonb_op(:settings).has_key?('pin') => false, status: %w[active finished], title: ['21Moon']).select(:id).paged_each(rows_per_fetch: 1) do |game|
    puts game[:id]
    games = Game.eager(:user, :players).where(id: [game[:id]]).all
    games.each do |game|
      puts "Migrating game: #{game.id}"
      migrate_db_actions(game)
    end
  end
end
