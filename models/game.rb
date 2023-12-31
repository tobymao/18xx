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
        AND (:title IS NULL OR :title = title)
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
        AND (:title IS NULL OR :title = g.title)
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

  def self.home_games(user, **opts)
    Bus.cache("home_games:#{user&.id}", ttl: 9, skip: !opts.empty?) do
      kwargs = {
        new_offset: opts['new'],
        active_offset: opts['active'],
        finished_offset: opts['finished'],
      }.transform_values { |v| v&.to_i || 0 }

      kwargs[:user_id] = user.id if user
      kwargs[:title] = opts['title'] != '' ? opts['title'] : nil
      kwargs[:status] = %w[new active]
      kwargs[:limit] = 1000
      fetch(user ? LOGGED_IN_QUERY : LOGGED_OUT_QUERY, **kwargs).all.map(&:to_h)
    end
  end

  def self.profile_games(user)
    Bus.cache("profile_games:#{user.id}", ttl: 60) do
      fetch(USER_QUERY, { user_id: user.id, status: %w[new active archived finished], limit: 100 }).all.map(&:to_h)
    end
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
      .shuffle(random: Random.new(settings['seed'] || settings['seed_v2'] || 1))
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

  def to_h(include_actions: false, logged_in_user_id: nil)
    actions_h = include_actions ? actions.map(&:to_h) : []
    if !players.find { |p| p.id == logged_in_user_id } && user_id != logged_in_user_id
      actions_h.reject! { |a| a['type'] == 'message' }
    end
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
      actions: actions_h,
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
end
