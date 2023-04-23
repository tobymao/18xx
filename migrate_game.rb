# frozen_string_literal: true
# rubocop:disable all

require_relative 'models'

Dir['./models/**/*.rb'].sort.each { |file| require file }

Sequel.extension :pg_json_ops
require_relative 'lib/engine'

$broken = {}

def switch_actions(actions, first, second)
  first_idx = actions.index(first)
  second_idx = actions.index(second)

  id = second['id']
  second['id'] = first['id']
  first['id'] = id

  actions[first_idx] = second
  actions[second_idx] = first
  return [first, second]
end

# Returns either the actions that are modified inplace, or nil if inserted/deleted

def repair(game, original_actions, actions, broken_action)
  optionalish_actions = %w[message buy_company]
  action_idx = actions.index(broken_action)
  action = broken_action['original_id'] || broken_action['id']
  puts "http://18xx.games/game/#{game.id}?action=#{action}"
  puts game.active_step
  prev_actions = actions[0..action_idx - 1]
  prev_action = prev_actions[prev_actions.rindex { |a| !optionalish_actions.include?(a['type']) }]
  next_actions = actions[action_idx + 1..]
  next_action = next_actions.find { |a| !optionalish_actions.include?(a['type']) }
  puts broken_action

  add_pass = lambda do
    pass = Engine::Action::Pass.new(game.active_step.current_entity)
    pass.user = pass.entity.player.id
    actions.insert(action_idx, pass.to_h)
  end

  if broken_action['type'] == 'move_token'
    # Move token is now place token.
    broken_action['type'] = 'place_token'
    return [broken_action]
  elsif game.is_a?(Engine::Game::G18USA::Game)
    if broken_action['type'] == 'pass'
      actions.delete(broken_action)
    elsif prev_action['type'] == 'pass'
      actions.delete(prev_action)
    end
    return
  elsif game.is_a?(Engine::Game::G21Moon::Game) and game.active_step.is_a?(Engine::Step::BuySellParShares)
    add_pass.call
    return
  elsif broken_action['type'] == 'buy_tokens'
    # 1817 no longer needs buy tokens
    actions.delete(broken_action)
    return
  elsif game.active_step.is_a?(Engine::Step::HomeToken) &&
    game.is_a?(Engine::Game::G1817WO)
    # Find the next place token by this corp
    entity = game.active_step.current_entity
    home_token = next_actions.find {|a| a['type']=='place_token' && a['entity']==entity.id}
    raise "can't find home tokenage" unless home_token
    home_token_h = home_token.to_h
    actions.delete(home_token)
    actions.insert(action_idx, home_token_h)
    return
  elsif broken_action['type'] == 'pass' &&
    game.active_step.is_a?(Engine::Game::G1817::Step::BuySellParShares) &&
    broken_action['entity'] == prev_action['entity']
    actions.delete(broken_action)
    return
  elsif broken_action['type'] == 'place_token' && game.is_a?(Engine::Game::G1867)
    # Stub changed token numbering
    hex_id = broken_action['city'].split('-')[0]
    hex = game.hex_by_id(hex_id)
    raise 'multiple city' unless hex.tile.cities.one?

    broken_action['city'] = hex.tile.cities.first.id
    return [broken_action]
  elsif game.active_step.is_a?(Engine::Game::G18SJ::Step::ChoosePriority)
    choice = Engine::Action::Choose.new(game.active_step.current_entity, choice: 'wait')
    choice.user = choice.entity.player.id
    actions.insert(action_idx, choice.to_h)
    return
  elsif game.active_step.is_a?(Engine::Step::BuyCompany) ||
    game.active_step.is_a?(Engine::Game::G1817::Step::PostConversion) ||
    game.active_step.is_a?(Engine::Game::G1817::Step::BuySellParShares) ||
    game.active_step.is_a?(Engine::Game::G1867::Step::SingleItemAuction) ||
    game.active_step.is_a?(Engine::Game::G1817::Step::Loan)
    add_pass.call
    return
  elsif game.active_step.is_a?(Engine::Game::G18Ireland::Step::Merge)
    add_pass.call
    return
  elsif game.active_step.is_a?(Engine::Game::G1817::Step::Acquire) && broken_action['type'] != 'pass'
    add_pass.call
    return
  elsif game.active_step.is_a?(Engine::Step::BuySellParShares) && game.is_a?(Engine::Game::G1867) && broken_action['type']=='bid'
    add_pass.call
    return
  elsif game.active_step.is_a?(Engine::Game::G1889::Step::SpecialTrack)
    # laying track for Ehime Railway didn't always block, now it needs an
    # explicit pass
    if broken_action['entity'] != 'ER'
      add_pass.call
      return
    end
  elsif game.active_step.is_a?(Engine::Game::G1867::Step::Merge) && broken_action['type'] != 'pass'
    add_pass.call
    return
  elsif game.is_a?(Engine::Game::G18CO) &&
          game.active_step.is_a?(Engine::Step::CorporateBuyShares) &&
          broken_action['type'] == 'pass'
    # 2P train should have been removed from the game, not put into the discard
    actions.delete(broken_action)
    return
  elsif game.is_a?(Engine::Game::G18CO) &&
    (game.active_step.is_a?(Engine::Step::Token) || game.active_step.is_a?(Engine::Step::Route))
    # Need to add a pass when the player has the GJGR private
    add_pass.call
    return
  elsif broken_action['type'] == 'pass'
    if game.active_step.is_a?(Engine::Game::G1817::Step::PostConversionLoans)
      actions.delete(broken_action)
      return
    end
    if game.active_step.is_a?(Engine::Game::G1867::Step::PostMergerShares)
      actions.delete(broken_action)
      return
    end
    if game.active_step.is_a?(Engine::Game::G1817::Step::Acquire)
      # Remove corps passes that went into acquisition
      if (game.active_step.current_entity.corporation? && broken_action['entity_type'] == 'player')
        action2 = Engine::Action::Pass.new(game.active_step.current_entity).to_h
        broken_action['entity'] = action2['entity']
        broken_action['entity_type'] = action2['entity_type']
        return [broken_action]
      else
        actions.delete(broken_action)
      end
      return
    end
    if game.active_step.is_a?(Engine::Game::G1867::Step::Merge)
      # Remove corps passes that went into acquisition
      actions.delete(broken_action)
      return
    end
    if game.active_step.is_a?(Engine::Game::G1817::Step::Conversion)
      # Remove corps passes that went into acquisition
      actions.delete(broken_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::Route) || game.active_step.is_a?(Engine::Step::BuyTrain)
      # Lay token sometimes needed pass when it shouldn't have
      actions.delete(broken_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::Track)
      # some games of 1889 didn't skip buy train
      actions.delete(broken_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::BuySellParShares)
      # some games of 1889 didn't skip the buy companies step correctly
      actions.delete(broken_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::IssueShares)
      # some 1846 pass too much
      actions.delete(broken_action)
      return
    end
    if game.is_a?(Engine::Game::G1836Jr30)
      # Shouldn't need to pass when buying trains
      if prev_action['type'] == 'buy_train'
        # Delete the pass
        actions.delete(broken_action)
        return
      end
    end
  elsif broken_action['type'] == 'lay_tile'
    if game.active_step.is_a?(Engine::Step::BuyCompany)
      add_pass.call
      return
    end
    if game.active_step.is_a?(Engine::Step::BuyTrain) && game.active_step.actions(game.active_step.current_entity).include?('pass')
      add_pass.call
      return
    end
    if game.active_step.is_a?(Engine::Step::IssueShares)
      add_pass.call
      return
    end
    if game.active_step.is_a?(Engine::Step::Route) and prev_action['type'] == 'pass'
      actions.delete(prev_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::Token) and prev_action['type'] == 'pass'
      actions.delete(prev_action)
      return
    end
  elsif broken_action['type'] == 'buy_train'
    if prev_action['type'] == 'pass' && game.active_step.is_a?(Engine::Step::Track)
      # Remove the pass, as it was probably meant for a token
      actions.delete(prev_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::DiscardTrain) && next_action['type'] == 'discard_train'
      return switch_actions(original_actions, broken_action, next_action)
    end
    if game.active_step.is_a?(Engine::Step::Track)
      add_pass.call
      return
    end
    if game.active_step.is_a?(Engine::Step::Token)
      add_pass.call
      return
    end
    if game.active_step.is_a?(Engine::Step::BuyCompany) && prev_action['type'] == 'pass'
      actions.delete(prev_action)
      return
    end
  elsif broken_action['type'] == 'run_routes'
    if game.active_step.is_a?(Engine::Step::Dividend) && prev_action['type'] == 'run_routes'
      actions.delete(prev_action)
      return
    end
    if game.active_step.is_a?(Engine::Step::Track)
      add_pass.call
      return
    end
    if game.active_step.is_a?(Engine::Step::Token)
      add_pass.call
      return
    end
  elsif broken_action['type']=='place_token' &&
    ['D6-0-3','298-0-2'].include?(broken_action['city']) &&
    game.companies.find { |company| company.name == 'Chicago and Western Indiana' }&.owner == game.active_step.current_entity
    # Move token lay from corp to private
    broken_action['entity'] = 'C&WI'
    broken_action['entity_type'] = 'company'
    return [broken_action]
  elsif game.active_step.is_a?(Engine::Step::Token)
    add_pass.call
    return

  elsif game.active_step.is_a?(Engine::Step::TrackAndToken)
    if ['buy_shares','sell_shares'].include?(broken_action['type']) and prev_action['type'] == 'pass'
      # Stray pass from buy companies
      actions.delete(prev_action)
      return
    end
    add_pass.call
    return
  elsif game.active_step.is_a?(Engine::Step::IssueShares) && broken_action['type']=='buy_company'
    # Stray pass from buy trains
    actions.delete(prev_action)
    return
  elsif broken_action['type'] == 'dividend' and broken_action['entity_type'] == 'minor'
    actions.delete(broken_action)
    return
  end

  puts "Game think it's #{game.active_step.current_entity.id} turn"
  raise Exception, "Cannot fix http://18xx.games/game/#{game.id}?action=#{action}"
end

def attempt_repair(actions, debug)
  repairs = []
  rewritten = false
  ever_repaired = false
  iteration = 0
  loop do
    game = yield
    game.instance_variable_set(:@loading, true)
    # Locate the break
    repaired = false
    filtered_actions, _active_undos = game.class.filtered_actions(actions)
    filtered_actions.compact!

    filtered_actions.each.with_index do |action, _index|
      action = action.copy(game) if action.is_a?(Engine::Action::Base)
      begin
        game.process_action(action).maybe_raise!
      rescue Exception => e
        puts e.backtrace if debug
        iteration += 1
        puts "Break at #{e} #{action} #{iteration}"
        raise Exception, "Stuck in infinite loop?" if iteration > 100

        ever_repaired = true
        inplace_actions = repair(game, actions, filtered_actions, action)
        repaired = true
        if inplace_actions
          repairs += inplace_actions
        else
          rewritten = true
          # Added or moved actions... destroy undo states and renumber.
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
    data['actions'], repairs = attempt_repair(data['actions'], debug) do
      Engine::Game.load(data, actions: []).maybe_raise!
    end
  rescue Exception => e
    puts 'Failed to fix :(', e
    return data
  end

  # running a migration on a game without issues returns nil actions
  return unless data['actions']

  data
end

# This doesn't write to the database
def migrate_db_actions_in_mem(data)
  original_actions = data.actions.map(&:to_h)

  begin
    actions, repairs = attempt_repair(original_actions) do
      Engine::Game.load(data, actions: []).maybe_raise!
    end
    puts repairs
    return actions || original_actions
  rescue Exception => e
    puts 'Something went wrong', e
    #raise e

  end
  return original_actions
end

def migrate_db_actions(data, pin, dry_run=false, debug=false)
  raise Exception, "pin is not valid" unless pin

  original_actions = data.actions.map(&:to_h)
  begin
    actions, repairs = attempt_repair(original_actions, debug) do
      Engine::Game.load(data, actions: []).maybe_raise!
    end
    if actions && !dry_run
      if repairs
        repairs.each do |action|
          # Find the action index
          idx = actions.index(action)
          data.actions[idx].action = action
          data.actions[idx].save
        end
      else # Full rewrite.
        DB.transaction do
          Action.where(game: data).delete
          game = Engine::Game.load(data, actions: []).maybe_raise!
          # Set back to loading
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
    $broken[data.id]=e
    puts e.backtrace if debug
    puts 'Something went wrong', e
    if !dry_run
      if pin == :delete || pin == :archive
        puts "Archiving #{data.id}"
        data.archive!
      else
        puts "Pinning #{data.id} to #{pin}"
        data.settings['pin']=pin
        data.save
      end
    else
      puts "Needs pinning #{data.id} to #{pin}"
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

def db_to_json(id, filename)
  game = Game[id]
  json = game.to_h(include_actions: true)

  File.write(filename, JSON.pretty_generate(json))
end

def migrate_db_to_json(id, filename)
  game = Game[id]
  json = game.to_h(include_actions: true)
  json['actions'] = migrate_db_actions(game)
  File.write(filename, JSON.pretty_generate(json))
end

# Pass pin=:archive to archive failed games
def migrate_title(title, pin, dry_run=false, debug = false)
  DB[:games].order(:id).where(Sequel.pg_jsonb_op(:settings).has_key?('pin') => false, status: %w[active finished], title: title).select(:id).paged_each(rows_per_fetch: 1) do |game|
    games = Game.eager(:user, :players, :actions).where(id: [game[:id]]).all
    games.each {|data|
      migrate_db_actions(data, pin, dry_run, debug)
    }

  end
end

def migrate_all(pin, dry_run=false, debug = false, game_ids: nil)
  where_args = {
    Sequel.pg_jsonb_op(:settings).has_key?('pin') => false,
    status: %w[active finished],
  }
  where_args[:id] = game_ids if game_ids

  DB[:games].order(:id).where(**where_args).select(:id).paged_each(rows_per_fetch: 1) do |game|
    games = Game.eager(:user, :players, :actions).where(id: [game[:id]]).all
    games.each {|data|
      migrate_db_actions(data, pin, dry_run, debug)
    }

  end
end
