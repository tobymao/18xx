# frozen_string_literal: true

require 'json'
require 'pp'

require_relative 'validate'

def validate(**kwargs)
  validate_kwargs = kwargs.dup

  k = lambda do |key, default|
    if kwargs.include?(key)
      kwargs.delete(key)
    else
      default
    end
  end

  ignore_git = k.call(:ignore_git, false)
  git_info = {
    branch: `git branch --show-current`.chomp,
    commit: `git rev-parse --short --verify HEAD`.chomp,
    diff: `git diff`.chomp + `git diff --cached`.chomp,
  }
  if git_info[:diff] != '' && !ignore_git
    puts 'Found uncommitted changes. Aborting.'
    puts 'Commit/reset your changes, or run again with `ignore_git: true`'
    return
  end

  desc_default =
    if Array(kwargs[:id]).one?
      Array(kwargs[:id])[0]
    elsif Array(kwargs[:title]).one?
      Array(kwargs[:title])[0]
    else
      ''
    end
  desc = k.call(:desc, desc_default)

  force = k.call(:force, false)
  filename = k.call(:filename, "validate_#{desc}.json")
  if File.exist?(filename) && !force
    puts "#{filename} already exists. Clean it up or choose a different filename."
    puts 'goodbye'
    return
  end

  # ask user for confirmation if more than this many games will be processed
  prompt_threshold = k.call(:prompt_threshold, 100)
  process_count = k.call(:process_count, :max)
  fork_retries = k.call(:fork_retries, 5)
  page_size = k.call(:page_size, 10)
  strict = k.call(:strict, true)
  # suppress "running game <id>" output for given titles
  quiet = k.call(:quiet, true)
  # validate related titles
  families = k.call(:families, true)
  # include stack trace in JSON when error found
  trace = k.call(:trace, true)
  show_slices = k.call(:show_slices, false)
  cleanup_fork_files = k.call(:cleanup_fork_files, true)

  validate_result = k.call(:validate_result, true)

  # remaining kwargs are forwarded to the DB#where()

  lock_file = "validate/validate_#{desc}.lock"
  if File.exist?(lock_file)
    puts "#{desc}: found #{lock_file}"
    puts "#{desc}: enusre previous processes using #{lock_file} are complete, then clean it and any related JSON files up"
    puts "#{desc}: goodbye"
    return
  end

  FileUtils.mkdir_p('validate')
  File.write(lock_file, '')

  if kwargs[:title] && families
    kwargs[:title] = Array(kwargs[:title]).flat_map do |title|
      titles_for_game_family(title)
    end.uniq.sort
  end

  pin_key = Sequel.pg_jsonb_op(:settings).has_key?('pin') # rubocop:disable Style/PreferredHashMethods
  where_kwargs = {
    pin_key => false,
    :status => %w[active finished],
  }.merge(kwargs)
  puts "#{desc}: Finding game IDS for:"

  kwargs_to_print = where_kwargs.except(pin_key)
  kwargs_to_print[:id] = [*kwargs_to_print[:id][0...10], '...'] if (kwargs_to_print[:id] || []).size > 10
  pp kwargs_to_print

  selected_ids = DB[:games].order(:id).where(**where_kwargs).select(:id).all.map { |g| g[:id] }
  game_count = selected_ids.size
  puts "#{desc}: Found #{game_count} matching games in range: #{selected_ids.minmax.join(' to ')}"

  # disconnect before starting connections in the forked processes
  DB.disconnect

  process_count =
    case process_count
    when :max
      [Etc.nprocessors - 1, game_count].min
    else
      [[[Etc.nprocessors - 1, process_count.to_i].min, 1].max, game_count].min
    end
  puts "#{desc}: Will fork into #{process_count} processes" if process_count > 1

  if prompt_threshold && game_count > prompt_threshold
    print "#{desc}: Type #{game_count} to confirm you wish to proceed (with #{process_count} processes): "
    if gets.chomp.to_i != game_count
      puts "#{desc}: User input did not match game count. Exiting valdiation."
      return FileUtils.rm(lock_file)
    end
  end

  start_time = Time.now
  ids = selected_ids.dup
  loop_id_counts = []
  data = { 'processes' => {} }
  total_processes = 0
  loop do
    puts "#{desc}: failed to process #{ids.size} games. Forking again..." if loop_id_counts.size.positive?

    first_process = loop_id_counts.size * process_count
    last_process = first_process + process_count - 1
    total_processes += process_count

    slices = get_slices(process_count, ids, show_slices)
    process_slices(slices, page_size, desc, strict, quiet, trace, fork_retries, index_delta: first_process,
                                                                                validate_result: validate_result)

    data = combine_forked_data!(data, desc, (first_process..last_process))

    loop_id_counts << ids.size
    ids = data.except('processes').filter_map { |id, g| g.empty? && id.to_i }
    break if ids.empty? || (ids.size == loop_id_counts.last)
  end

  wall_time = Time.now - start_time

  finished = ids.empty?
  puts "#{desc}: #{ids.size} left unprocessed" unless finished

  puts "#{desc}: needed #{loop_id_counts.size} loops"

  total_games = selected_ids.size
  failed = data.count { |_id, g| g['exception'] }
  total_time = data.sum { |_id, g| g['time']&.to_i || 0 }
  avg_time = total_time / total_games

  data['summary'] = {
    'processes' => data.delete('processes'),
    'failed_ids' => data.select { |_id, g| g['exception'] }.map { |id, _g| id.to_i }.sort,
    'failed' => failed,
    'total' => total_games,
    'total_time' => total_time,
    'avg_time' => avg_time,
    'wall_time' => wall_time,
    'wall_time_avg' => wall_time / total_games,
    'kwargs' => validate_kwargs,
    'git_info' => git_info,
  }

  puts ''
  pp data['summary'].except('kwargs')

  File.write(filename, JSON.pretty_generate(data))

  FileUtils.rm(lock_file)

  if cleanup_fork_files
    total_processes.times.each do |index|
      filename = format("validate/validate_#{desc}_%03d.json", index)
      data = File.exist?(filename) ? JSON.parse(File.read(filename)) : {}
      if finished || data.dig('processes', index.to_s, 'finished_validation')
        FileUtils.rm(filename)
      else
        puts "process #{index} did not finish, keeping #{filename}"
      end
    end
  end

  Validate.new("validate_#{desc}.json")
end

def get_slices(process_count, ids, show_slices)
  slices = []
  process_count.times { slices << [] }
  ids.each.with_index do |id, index|
    slices[index % process_count] << id
  end
  pp slices if show_slices
  slices
end

def process_slices(slices, page_size, desc, strict, quiet, trace, fork_retries, index_delta: 0, validate_result: true)
  pids = slices.map.with_index do |slice_ids, i|
    next if slice_ids.nil?

    index = i + index_delta

    filename = format("validate/validate_#{desc}_%03d.json", index)

    Process.fork do
      @attempts = 0
      begin
        # spread out the forks attacking the database
        sleep(index)

        puts "#{desc}: Process #{index} (#{slice_ids.size} games) started at #{Time.now.utc}"

        data = { 'processes' => { index.to_s => { 'finished_validation' => false } }, **slice_ids.to_h { |id| [id, {}] } }
        File.write(filename, JSON.pretty_generate(data))
        data = nil

        pages = slice_ids.each_slice(page_size)
        pages.with_index do |ids, idx|
          page_data = {}

          puts "#{desc}: Process #{index}: starting page #{idx}/#{pages.size}..."

          Game.eager(:user, :players, :actions).where(id: ids).all.each do |game|
            page_data[game.id] = run_game(game, strict: strict, silent: quiet, trace: trace, validate_result: validate_result)
          end

          file_data = JSON.parse(File.read(filename))
          File.write(filename, JSON.pretty_generate(file_data.merge(page_data)))
          page_data = nil

          data = JSON.parse(File.read(filename))
          processed_count = data.count { |id, g| id != 'processes' && !g.empty? }
          puts "#{desc}: Process #{index} finished running #{page_size} games, #{processed_count}/#{slice_ids.size} total..."
          data = nil
        end

        data = JSON.parse(File.read(filename))
        data['processes'][index.to_s] = { finished_validation: true }
        processed_count = data.count { |id, g| id != 'processes' && !g.empty? }
        puts "#{desc}: Process #{index} (processed #{processed_count}/#{slice_ids.size}) finished at #{Time.now.utc}"
        File.write(filename, JSON.pretty_generate(data))
        data = nil
      rescue Exception => e # rubocop:disable Lint/RescueException
        @attempts += 1
        puts "#{desc}: Process #{index} (#{slice_ids.size} games) encountered an error at #{Time.now.utc}:\n#{e.inspect}"
        if @attempts < fork_retries
          # exponential backoff to retry
          sleep_time = 2**@attempts
          puts "#{desc}: sleeping #{sleep_time} seconds then retrying "\
               "Process #{index}, attempt #{@attempts + 1}/#{fork_retries}..."
          sleep(sleep_time)
          retry
        end

        data = JSON.parse(File.read(filename))
        data['processes'] = {
          index.to_s => { :finished_validation => false, 'exception' => e.inspect, 'stack' => e.backtrace },
        }
        File.write(filename, JSON.pretty_generate(data))
        data = nil
      end
    end
  end
  pids.compact.each { |pid| Process.waitpid(pid) }
end

def combine_forked_data!(data, desc, processes)
  files = processes.map do |process|
    format("validate/validate_#{desc}_%03d.json", process)
  end

  files.each do |f|
    forked_data = JSON.parse(File.read(f))
    data['processes'].merge!(forked_data.delete('processes'))
    data.merge!(forked_data)
  end

  data
end
