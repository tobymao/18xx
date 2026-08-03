# frozen_string_literal: true

require_relative 'base'
require_relative '../lib/bus'

class Game < Base
  many_to_one :user
  one_to_many :actions, order: :action_id
  one_to_many :game_users
  many_to_many :players, class: :User, right_key: :user_id, join_table: :game_users

  QUERY_LIMIT = 13

  STATUS_QUERY = <<~SQL.freeze
    SELECT %<status>s_games.*
    FROM (
      SELECT *
      FROM games
      WHERE status = '%<status>s'
        AND (:titles IS NULL OR title = ANY(:titles))
        AND (:mode IS NULL OR COALESCE((settings->>'is_async')::boolean, true) = (:mode = 'async'))
        AND NOT (status = 'new' AND COALESCE((settings->>'unlisted')::boolean, false))
      ORDER BY created_at DESC
      LIMIT #{QUERY_LIMIT}
      OFFSET :%<status>s_offset * #{QUERY_LIMIT - 1}
    ) %<status>s_games
  SQL

  USER_STATUS_QUERY = <<~SQL.freeze
    SELECT %<status>s_games.*
    FROM (
      SELECT g.*
      FROM games g
      LEFT JOIN user_games ug
        ON g.id = ug.id
      WHERE g.status = '%<status>s'
        AND (:titles IS NULL OR g.title = ANY(:titles))
        AND (:mode IS NULL OR COALESCE((g.settings->>'is_async')::boolean, true) = (:mode = 'async'))
        AND ug.id IS NULL
        AND NOT (g.status = 'new' AND COALESCE((settings->>'unlisted')::boolean, false))
      ORDER BY g.%<ordered_by>s DESC
      LIMIT #{QUERY_LIMIT}
      OFFSET :%<status>s_offset * #{QUERY_LIMIT - 1}
    ) %<status>s_games
  SQL

  USER_QUERY = <<~SQL
    WITH user_games AS (
      select game_id AS id
      from game_users
      where user_id = :user_id
    )

    SELECT personal_games.*
    FROM (
      SELECT g.*
      FROM games g
      LEFT JOIN user_games ug
        ON g.id = ug.id
      WHERE (ug.id IS NOT NULL OR g.user_id = :user_id)
        AND g.status IN :status
      ORDER BY g.id DESC
      LIMIT :limit
    ) personal_games
  SQL

  # rubocop:disable Style/FormatString
  LOGGED_OUT_QUERY = <<~SQL.freeze
    #{STATUS_QUERY % { status: 'new' }}
    UNION
    #{STATUS_QUERY % { status: 'active' }}
    UNION
    #{STATUS_QUERY % { status: 'finished' }}
  SQL

  LOGGED_IN_QUERY = <<~SQL.freeze
    #{USER_QUERY}
    UNION
    #{USER_STATUS_QUERY % { status: 'new', ordered_by: 'created_at' }}
    UNION
    #{USER_STATUS_QUERY % { status: 'active', ordered_by: 'created_at' }}
    UNION
    #{USER_STATUS_QUERY % { status: 'finished', ordered_by: 'created_at' }}
  SQL
  # rubocop:enable Style/FormatString

  # Cap how deep offset paging can go -- well past any real page count, but finite
  # so the cache key space can't be grown unbounded by arbitrary offsets.
  HOME_OFFSET_MAX = 10_000
  # Logged-out visitors get a far shallower cap: no anonymous session browses
  # hundreds of pages deep, and the small cap keeps the shared (user-less) cache
  # key space tiny, so walking offsets collapses onto a few cached pages instead
  # of an endless stream of distinct, uncached DB queries.
  ANON_OFFSET_MAX = 10

  def self.home_games(user, **opts)
    offset_max = user ? HOME_OFFSET_MAX : ANON_OFFSET_MAX
    offsets = {
      new_offset: opts['new'],
      active_offset: opts['active'],
      finished_offset: opts['finished'],
    }.transform_values { |v| (v&.to_i || 0).clamp(0, offset_max) }

    # Normalize titles to the valid, sorted set (an all-invalid request still
    # filters to nothing rather than falling back to every game).
    requested = Array(opts['title']).map(&:strip).reject(&:empty?)
    titles = requested.empty? ? nil : (requested & Engine::GAME_TITLES).sort

    mode = opts['mode']&.strip
    mode = nil unless %w[live async].include?(mode)

    # Key the cache on the *normalized* query inputs so equivalent or junk params
    # (e.g. "01" vs "1", unknown titles/modes) collapse to one key instead of
    # minting an unbounded number of distinct entries.
    key = [offsets.values, titles, mode]
    Bus.cache("home_games:#{user&.id}:#{key}", ttl: 9) do
      kwargs = offsets.dup
      kwargs[:user_id] = user.id if user
      # Typed so an all-invalid request (empty array) still binds as text[] rather
      # than raising IndeterminateDatatype; it just matches no rows.
      kwargs[:titles] = titles && Sequel.pg_array(titles, :text)
      kwargs[:mode] = mode
      kwargs[:status] = %w[new active]
      kwargs[:limit] = 1000
      to_h_safe(fetch(user ? LOGGED_IN_QUERY : LOGGED_OUT_QUERY, **kwargs).all)
    end
  end

  def self.profile_games(user)
    Bus.cache("profile_games:#{user.id}", ttl: 60) do
      games = fetch(USER_QUERY, { user_id: user.id, status: %w[new active archived finished], limit: 100 })
              .all
              .reject { |g| g.status == 'new' && g.settings['unlisted'] }
      to_h_safe(games)
    end
  end

  def self.next_for_user(user)
    return unless user

    where(status: 'active')
      .where(Sequel.lit('acting @> ARRAY[?]::integer[]', user.id))
      .all
      .filter_map { |game| next_for_user_candidate(game) }
      .min_by { |candidate| [candidate[:waiting_since], candidate[:game].id] }
      &.fetch(:game)
  end

  def self.to_h_safe(games)
    games.filter_map do |game|
      game.to_h
    rescue StandardError => e
      warn "Skipping unloadable game #{game.id}: #{e}"
      nil
    end
  end

  def self.next_for_user_candidate(game)
    engine = Engine::Game.load(game)
    turn_start_action_id = engine.turn_start_action_id
    waiting_since =
      (Action.where(game_id: game.id, action_id: turn_start_action_id).get(:created_at) if turn_start_action_id&.positive?)

    { game: game, waiting_since: waiting_since || game.updated_at || game.created_at }
  rescue StandardError => e
    warn "Skipping unloadable game #{game.id}: #{e}"
    nil
  end

  SETTINGS = %w[
    notepad
  ].freeze
  def update_player_settings(player, params)
    clean_params = params.filter { |k, _v| SETTINGS.include? k }
    settings['players'] ||= {}
    settings['players'][player] = (settings['players'][player] || {}).merge(clean_params)
  end

  def ordered_players
    return players.sort_by { |p| settings['player_order'].find_index(p.id) || p.id } if settings['player_order']

    players
      .sort_by(&:id)
      .shuffle(random: Random.new(settings['seed'] || 1))
  end

  def finished_at_ts
    finished_at&.to_i
  end

  def archive!
    Action.where(game: self).delete
    settings.delete('pin')
    archive_data = { status: 'archived', settings: settings }
    unless finished_at
      archive_data[:finished_at] = updated_at
      archive_data[:manually_ended] = true
    end
    update(archive_data)
  end

  def to_h(include_actions: false, logged_in_user_id: nil, admin: false)
    settings_h = settings.to_h

    # Move user settings and hide from other players
    user_settings_h = settings_h.dig('players', logged_in_user_id.to_s)
    settings_h.delete('players')

    {
      id: id,
      description: description,
      user: user.to_h,
      players: ordered_players.map(&:to_h),
      min_players: min_players,
      max_players: max_players,
      title: title,
      settings: settings_h,
      user_settings: user_settings_h,
      status: status,
      turn: turn,
      round: round,
      acting: acting.to_a,
      result: result.to_h,
      actions: actions_h(include_actions: include_actions, logged_in_user_id: logged_in_user_id, admin: admin),
      loaded: include_actions,
      created_at: created_at_ts,
      updated_at: updated_at_ts,
      finished_at: finished_at_ts,
    }
  end

  def validate
    super
    errors.add(:finished_at, 'must be set for finished games') if status == 'finished' && !finished_at
  end

  # Remove chat messages for players not in the game. Keeps the chat action (but
  # removes the `message` contents) if the action is the target for an undo, or
  # if it has auto actions attached. Admins always see the full chat.
  def actions_h(include_actions: false, logged_in_user_id: nil, admin: false)
    return [] unless include_actions

    remove_messages = !admin && players.none? { |p| p.id == logged_in_user_id } && user_id != logged_in_user_id
    undo_targets = actions.filter_map { |a| a.action['type'] == 'undo' && a.action['action_id'] }.to_set

    actions.filter_map do |db_action|
      action = db_action.to_h
      if remove_messages && action['type'] == 'message'
        # rubocop:disable Style/GuardClause
        if undo_targets.include?(action['id']) || (action['auto_actions'] && !action['auto_actions'].empty?)
          action['message'] = ''
        else
          next
        end
        # rubocop:enable Style/GuardClause
      end
      action
    end
  end
end
