# frozen_string_literal: true
# rubocop:disable all

if __FILE__ == $0 && ARGV[0]
  require 'json'
  require_relative '../lib/engine'
  Engine::Logger.set_level(Logger::FATAL)
else
  require_relative 'scripts_helper'
end

$broken = {}

module LegacyBuyTrain
  def actions(entity)
    return super unless @game.instance_variable_get(:@legacy_buy_train)
    return [] if !can_entity_buy_train?(entity) || entity != current_entity
    return %w[buy_train] if must_buy_train?(entity)
    if can_buy_train?(entity) || (!owns_2e?(entity) && entity.cash >= 100 && @game.can_take_loan?(entity))
      return %w[buy_train pass]
    end

    []
  end

  def buying_power(entity)
    return super unless @game.instance_variable_get(:@legacy_buy_train)

    @game.buying_power(entity)
  end
end
Engine::Game::G1848::Step::BuyTrain.prepend(LegacyBuyTrain)

def load_game(data, legacy: false)
  game = Engine::Game.load(data, actions: []).maybe_raise!
  game.instance_variable_set(:@legacy_buy_train, legacy)
  game.instance_variable_set(:@loading, true)
  game
end

def at_buy_train?(game)
  game.round.active_step.is_a?(Engine::Game::G1848::Step::BuyTrain)
end

def pass_action_hash(entity, source, auto_actions)
  {
    'type' => 'pass',
    'entity' => entity.id,
    'entity_type' => 'corporation',
    'user' => source['user'],
    'created_at' => source['created_at'],
    'auto_actions' => auto_actions,
  }.compact
end

def process_auto_actions(game, auto_actions)
  (auto_actions || []).each do |auto|
    game.process_single_action(Engine::Action::Base.action_from_h(auto, game))
  end
  game.maybe_raise!
end

def fingerprint(game)
  {
    round: [game.round.class.name, game.turn, game.round.round_num],
    current: game.current_entity&.id,
    finished: game.finished,
    result: game.finished ? game.result : nil,
    bank: game.bank.cash,
    phase: game.phase.name,
    loans: game.loans.size,
    players: game.players.map { |p| [p.id, p.cash, p.shares.map(&:id).sort, p.companies.map(&:id).sort] },
    corporations: game.corporations.map do |c|
      [c.id, c.cash, c.trains.map(&:id).sort, c.loans.size, c.share_price&.price, c.owner&.name, c.companies.map(&:id).sort]
    end,
  }
end

def attempt_repair(data, actions)
  legacy = load_game(data, legacy: true)
  game = load_game(data)
  filtered_actions, _active_undos = Engine::Game::Base.filtered_actions(JSON.parse(JSON.generate(actions)))
  filtered_actions.compact!

  result = []
  changes = 0

  filtered_actions.each do |action|
    auto_actions = action['auto_actions']
    main = action.reject { |k, _| k == 'auto_actions' }

    if at_buy_train?(legacy) && !at_buy_train?(game) && action['type'] == 'pass'
      legacy.process_action(main).maybe_raise!
      process_auto_actions(legacy, auto_actions)
      process_auto_actions(game, auto_actions)
      result.last['auto_actions'] = (result.last['auto_actions'] || []) + auto_actions if auto_actions
      changes += 1
      puts "        patched: deleted buy trains pass #{action['id']} from #{action['entity']}"
      next
    end

    legacy.process_action(main).maybe_raise!
    game.process_action(main).maybe_raise!

    if at_buy_train?(game) && !at_buy_train?(legacy)
      pass = pass_action_hash(game.current_entity, action, auto_actions)
      process_auto_actions(legacy, auto_actions)
      game.process_action(pass).maybe_raise!
      result << main << pass
      changes += 1
      puts "        patched: inserted buy trains pass for #{pass['entity']} after #{action['type']} #{action['id']}"
    else
      process_auto_actions(legacy, auto_actions)
      process_auto_actions(game, auto_actions)
      result << action
    end
  end

  return if changes.zero?

  expected = fingerprint(legacy)
  raise Exception, "Cannot fix Game #{game.id}: migrated state differs from original" unless fingerprint(game) == expected

  result.each_with_index do |a, idx|
    a['original_id'] = a['id'] if a['id'] && !a.include?('original_id')
    a['id'] = idx + 1
  end

  reloaded = Engine::Game.load(data, actions: result, strict: true)
  raise Exception, "Cannot fix Game #{game.id}: #{reloaded.exception.message}" if reloaded.exception
  raise Exception, "Cannot fix Game #{game.id}: reloaded state differs from original" unless fingerprint(reloaded) == expected

  result
end

def migrate_data(data, debug=true)
  begin
    actions = attempt_repair(data, data['actions'])
  rescue Exception => e
    puts e.backtrace if debug
    puts 'Failed to fix :(', e
    return data
  end

  return unless actions

  data['actions'] = actions
  data
end

def migrate_db_actions(data, pin=nil, dry_run=false, debug=false, require_pin: false)
  raise Exception, "pin is not valid" if !pin && require_pin

  puts "\nGame #{data.id}"

  original_actions = data.actions.map(&:to_h)
  begin
    actions = attempt_repair(data, original_actions)
    if actions && !dry_run
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

def migrate_json(filename, debug=true)
  puts "Loading #{filename} for migration"
  data = migrate_data(JSON.parse(File.read(filename)), debug)
  if data
    File.write(filename, JSON.pretty_generate(data))
  else
    puts 'Nothing to do, game works'
  end
end

# Pass pin=:archive to archive failed games
def migrate_title(title='1848', pin=nil, dry_run=false, debug=false, require_pin: false)
  DB[:games].order(:id).where(Sequel.pg_jsonb_op(:settings).has_key?('pin') => false, status: %w[active finished], title: title).select(:id).paged_each(rows_per_fetch: 1) do |game|
    games = Game.eager(:user, :players, :actions).where(id: [game[:id]]).all
    games.each { |data| migrate_db_actions(data, pin, dry_run, debug, require_pin: require_pin) }
  end
end

if __FILE__ == $0 && ARGV[0]
  ARGV.each { |f| migrate_json(f) }
end
