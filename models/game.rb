# frozen_string_literal: true

require_relative 'base'

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
      ORDER BY g.created_at DESC
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
      WHERE ug.id IS NOT NULL
        OR g.user_id = :user_id
      ORDER BY g.id DESC
      LIMIT 1000
    ) personal_games
  SQL

  # rubocop:disable Style/FormatString
  LOGGED_IN_QUERY = <<~SQL.freeze
    #{USER_QUERY}
    UNION
    #{USER_STATUS_QUERY % { status: 'new' }}
    UNION
    #{USER_STATUS_QUERY % { status: 'active' }}
    UNION
    #{USER_STATUS_QUERY % { status: 'finished' }}
  SQL

  LOGGED_OUT_QUERY = <<~SQL.freeze
    #{STATUS_QUERY % { status: 'new' }}
    UNION
    #{STATUS_QUERY % { status: 'active' }}
    UNION
    #{STATUS_QUERY % { status: 'finished' }}
  SQL
  # rubocop:enable Style/FormatString

  def self.home_games(user, **opts)
    kwargs = {
      new_offset: opts['new'],
      active_offset: opts['active'],
      finished_offset: opts['finished'],
    }.transform_values { |v| v&.to_i || 0 }

    kwargs[:user_id] = user.id if user
    kwargs[:title] = opts['title'] != '' ? opts['title'] : nil
    fetch(user ? LOGGED_IN_QUERY : LOGGED_OUT_QUERY, **kwargs,).all.sort_by(&:id).reverse
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
    update(status: 'archived')
  end

  def to_h(include_actions: false, logged_in_user_id: nil)
    actions_h = include_actions ? actions.map(&:to_h) : []
    actions_h.reject! { |a| a['type'] == 'message' } unless players.find { |p| p.id == logged_in_user_id }
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
end
