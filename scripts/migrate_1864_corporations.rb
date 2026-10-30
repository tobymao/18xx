# frozen_string_literal: true
# rubocop:disable all

if __FILE__ == $0 && ARGV[0]
  require 'json'
else
  require_relative 'scripts_helper'
end

CORP_MAP = {
  'RO' => 'RF&CC',
  'KB' => 'BW&GF',
  'OK' => 'CC&R',
  'KK' => 'SPP',
  'SPW' => 'CP',
  'MB' => 'M&P',
  'KR' => 'UCR',
  'N' => 'O&NW',
  'Y' => 'ICR',
  'M-K' => 'DPR',
  'MNN' => 'U&N',
  'MV' => 'NM&SP',
  'V' => 'SLS&E',
  'TR' => 'CCR',
  'SV' => 'CSR',
  'E' => 'O&C',
  'NW' => 'WP',
  'SW' => 'TP',
  'SE' => 'SP',
  'MVR' => 'NP',
  'MK' => 'MKT',
  'GRR' => 'GN',
  'MKN' => 'DRG',
  'MKV' => 'ATSF',
}.freeze

def migrate_share(share)
  corp, _, index = share.rpartition('_')
  CORP_MAP[corp] ? "#{CORP_MAP[corp]}_#{index}" : share
end

def fix_action(action)
  original = Marshal.load(Marshal.dump(action))

  %w[corporation tokener].each do |key|
    action[key] = CORP_MAP[action[key]] if CORP_MAP[action[key]]
  end
  action['entity'] = CORP_MAP[action['entity']] if action['entity_type'] == 'corporation' && CORP_MAP[action['entity']]
  action['target'] = CORP_MAP[action['target']] if action['target_type'] == 'corporation' && CORP_MAP[action['target']]
  action['shares'] = action['shares'].map { |share| migrate_share(share) } if action['shares']
  action['swap'] = migrate_share(action['swap']) if action['swap']
  (action['auto_actions'] || []).each { |auto_action| fix_action(auto_action) }

  action != original
end

def migrate_json(filename)
  data = JSON.parse(File.read(filename))
  updated = data['actions'].count { |action| fix_action(action) }
  File.write(filename, JSON.generate(data))
  puts "#{filename}: updated #{updated} actions"
end

def migrate_db_actions(game)
  updated = 0
  game.actions.each do |action|
    next unless fix_action(action.action)

    action.save
    updated += 1
  end
  puts "Game #{game.id}: updated #{updated} actions"
end

def migrate_one(id)
  Game.eager(:user, :players, :actions).where(id: id, title: '1864: Forty-Niner').all.each do |game|
    migrate_db_actions(game)
  end
end

def migrate_all
  DB[:games].order(:id).where(Sequel.pg_jsonb_op(:settings).has_key?('pin') => false, status: %w[active finished], title: '1864: Forty-Niner').select(:id).paged_each(rows_per_fetch: 1) do |game|
    migrate_one(game[:id])
  end
end

if __FILE__ == $0 && ARGV[0]
  ARGV.each { |filename| migrate_json(filename) }
end
