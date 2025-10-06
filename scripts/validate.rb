# frozen_string_literal: true
# rubocop:disable all

require 'json'
require_relative 'scripts_helper'
require_relative 'migrate_game'

class GameResultError < Engine::GameError
end

# class to facilitate interacting with the results of validate_all() in an irb
# console
class Validate
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def write(filename)
    @filename = filename
    File.write(filename, JSON.pretty_generate(data))
  end

  def parsed
    @parsed ||= JSON.parse(File.read(filename))
  end

  def data
    @data ||= parsed.reject { |k, v| k == 'summary' }
  end

  def summary
    @summary ||= parsed['summary']
  end

  def ids
    @ids ||= data.keys.map(&:to_i)
  end

  def titles
    @titles ||= data.map { |_id, g| g['title'] }.uniq.sort
  end

  def errors
    @errors ||= data.select { |_id, g| g['exception'] }
  end

  def error_ids
    @error_ids ||= errors.keys.map(&:to_i)
  end

  def error_titles
    @error_titles ||= errors.map { |_id, g| g['title'] }.uniq.sort
  end

  def error_ids_by_title
    @error_ids_by_title ||=
      begin
        _errors = errors.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(id, game), obj|
          obj[game['title']] << game['id']
        end
        _errors.transform_values!(&:sort)
        _errors
      end
  end

  def error_counts_by_title
    error_ids_by_title.transform_values(&:size)
  end

  def ids_to_act_on
    @ids_to_act_on ||=
      begin
        _ids_to_act_on = {'archive' => [], 'pin' => []}
        error_ids_by_title.each do |title, ids|
          key = {
            prealpha: 'archive',
            alpha: 'archive',
            beta: 'pin',
            production: 'pin',
          }[Engine.meta_by_title(title)::DEV_STAGE]
          _ids_to_act_on[key].concat(ids)
        end
        _ids_to_act_on.transform_values!(&:sort!)
      end
  end

  def ids_to_pin
    ids_to_act_on['pin']
  end

  def ids_to_archive
    ids_to_act_on['archive']
  end

  def pin_and_archive!(pin_version)
    pin_games(pin_version, ids_to_pin)
    archive_games(ids_to_archive)
  end
end

$count = 0
$total = 0
$total_time = 0

def run_game(game, actions = nil, strict: false, silent: false, trace: false, validate_result: true, return_engine: false)
  actions ||= game.actions.map(&:to_h)
  data = {
    'id' => game.id,
    'title' => game.title,
    'optional_rules' => game.settings['optional_rules'],
    'status' => game.status
  }

  puts "running game #{game.id}" unless silent

  $total += 1
  time = Time.now
  begin
    engine = Engine::Game.load(game, actions: actions, strict: strict)
  rescue Exception => e # rubocop:disable Lint/RescueException
    $count += 1
    data['finished_validation']=false
    data['exception']=e.inspect
    data['stack']=e.backtrace if trace
    return data
  end

  begin
    # maybe_raise! clears @broken_action, so grab it now
    broken_action = engine.broken_action&.to_h

    engine.maybe_raise!

    time = Time.now - time
    $total_time += time

    data['finished_validation']=true
    data['actions']=engine.actions.size
    data['result']=engine.result
    data['game_finished'] = engine.finished
    data['game_end_reason'] = engine.game_end_reason

    if validate_result
      errors = []

      unless engine.finished == (data['status'] == 'finished')
        errors << "got engine.finished=#{engine.finished} with data['status']=#{data['status']}"
      end

      engine_result = engine.result.transform_keys(&:to_s).sort_by { |_, v| v }.reverse.to_h
      db_result = game.result.transform_keys(&:to_s).sort_by { |_, v| v }.reverse.to_h
      if engine_result != db_result
        errors <<  "DB stored result #{db_result} does not match engine computed result #{engine_result}"
      end

      unless errors.empty?
        raise GameResultError, errors.join('; ')
      end
      # TODO -- :turn :round :acting
      # update :updated_at (or is this auto with migration?)
    end

  rescue Exception => e # rubocop:disable Lint/RescueException
    $count += 1
    data['url']="https://18xx.games/game/#{game.id}?action=#{engine.last_processed_action}"
    data['last_action']=engine.last_processed_action
    data['finished_validation']=false
    data['exception']=e.inspect
    data['broken_action']=broken_action
    data['stack']=e.backtrace if trace
  end

  data['engine'] = engine if return_engine

  data
end

def validate_all(*titles, families: true, game_ids: nil, strict: false, status: %w[active finished], filename: 'validate.json', silent: false, trace: true)
  $count = 0
  $total = 0
  $total_time = 0
  page = []
  data = {}

  titles =
    if families
      titles.flat_map do |title|
        titles_for_game_family(title)
      end.uniq.sort
    else
      titles.sort
    end

  where_args = {Sequel.pg_jsonb_op(:settings).has_key?('pin') => false, status: status}
  where_args[:title] = titles unless titles.empty?
  where_args[:id] = game_ids if game_ids

  puts "Finding game IDS for #{where_args}"

  DB[:games].order(:id).where(**where_args).select(:id).paged_each(rows_per_fetch: 100) do |game|
    page << game
    if page.size >= 100
      where_args2 = {id: page.map { |p| p[:id] }}
      where_args2[:title] = titles unless titles.empty?
      games = Game.eager(:user, :players, :actions).where(**where_args2).all
      _ = games.each do |game|
        data[game.id]=run_game(game, strict: strict, silent: silent, trace: trace)
      end
      page.clear
    end
  end

  where_args3 = {id: page.map { |p| p[:id] }}
  where_args3[:title] = titles unless titles.empty?

  games = Game.eager(:user, :players, :actions).where(**where_args3).all
  _ = games.each do |game|
    data[game.id]=run_game(game, strict: strict, silent: silent, trace: trace)
  end
  puts "#{$count}/#{$total} avg #{$total_time / $total}"
  data['summary']={'failed':$count, 'total':$total, 'total_time':$total_time, 'avg_time':$total_time / $total}

  File.write(filename, JSON.pretty_generate(data))
  Validate.new(filename)
end

def validate_one(id)
  game = Game[id]
  puts run_game(game)
end

def validate_migrated_one_mem(id)
  game = Game[id]
  puts run_game(game, migrate_db_actions_in_mem(game))
end
def validate_migrated_one(id)
  game = Game[id]
  puts run_game(game, migrate_db_actions(game))
end

def revalidate_broken(filename)
  $count = 0
  $total = 0
  $total_time = 0
  data = JSON.parse(File.read(filename))
  data = data.map do |game, val|
    if game != 'summary' && !val['finished'] && !val['pin']
      reload_game = Game[val['id']]
      d = run_game(reload_game, migrate_db_actions(reload_game))
      d['original']=val
      #[game,run_game(reload_game)]
      [game,d]
    end
  end.compact.to_h
  data['updated_summary']={'failed':$count, 'total':$total, 'total_time':$total_time, 'avg_time':$total_time / $total}
  File.write("revalidate.json", JSON.pretty_generate(data))
end

def validate_json(filename, strict: false)
  game = Engine::Game.load(filename, strict: strict)
  if game.exception
    puts game.broken_action.to_h
  end
  game.maybe_raise!
end

def validate_json_auto(filename, strict: false)
  # Validate the json, and try and add auto actions at the end
  data = JSON.parse(File.read(filename))
  rungame = Engine::Game.load(data, strict: strict).maybe_raise!
  rungame.maybe_raise!
  actions = rungame.class.filtered_actions(data['actions']).first

  action = actions.last

  # Process game to previous action
  auto_game = Engine::Game.load(data, at_action: action['id'] - 1)

  # Add the action but without the auto actions
  clone = action.dup
  clone.delete('auto_actions')
  auto_game.process_action(clone, add_auto_actions: true)
  auto_game.maybe_raise!
end

def pin_games(pin_version, game_ids)
  game_ids.each do |id|
    data = Game[id]
    if (pin = data.settings['pin'])
      puts "Game #{id} already pinned to #{pin}"
    else
      data.settings['pin'] = pin_version
    end
    data.save
  end
end

def archive_games(game_ids)
  game_ids.each do |id|
    Game[id].archive!
  end
end

# returns Array<String> for all titles related to this one via DEPENDS_ON and
# GAME_VARIANTS connections
def titles_for_game_family(title)
  titles = Set.new

  meta = Engine.meta_by_title(title)
  top = meta
  top = Engine.meta_by_title(top::DEPENDS_ON) until top::DEPENDS_ON.nil?

  dependent_metas = Engine::GAME_METAS.group_by { |m| m::DEPENDS_ON }
  metas = [top, *dependent_metas[top.title]]

  until metas.empty?
    meta = metas.pop
    title = meta.title
    next if titles.include?(title)

    titles.add(title)
    meta::GAME_VARIANTS.each do |variant|
      metas << Engine.meta_by_title(variant[:title])
    end
    metas.concat(dependent_metas[title] || [])
  end

  titles.sort
end
