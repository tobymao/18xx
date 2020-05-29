# frozen_string_literal: true

require_relative 'base'

class Game < Base
  many_to_one :user
  one_to_many :actions, order: :action_id
  one_to_many :game_users
  many_to_many :players, class: :User, right_key: :user_id, join_table: :game_users

  QUERY_LIMIT = 11

  STATUS_QUERY = <<~SQL
    SELECT %<status>s_games.*
    FROM (
      SELECT *
      FROM games
      WHERE status = '%<status>s'
      ORDER BY created_at DESC
      LIMIT #{QUERY_LIMIT}
      OFFSET :%<status>s_offset * #{QUERY_LIMIT - 1}
    ) %<status>s_games
  SQL

  USER_STATUS_QUERY = <<~SQL
    SELECT %<status>s_games.*
    FROM (
      SELECT g.*
      FROM games g
      LEFT JOIN user_games ug
        ON g.id = ug.id
      WHERE g.status = '%<status>s'
        AND ug.id IS NULL
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
      JOIN user_games ug
        ON g.id = ug.id
      WHERE g.status != 'finished'
      ORDER BY g.created_at DESC
      LIMIT #{QUERY_LIMIT}
      OFFSET :personal_offset * #{QUERY_LIMIT - 1}
    ) personal_games
  SQL

  # rubocop:disable Style/FormatString
  LOGGED_IN_QUERY = <<~SQL
    #{USER_QUERY}
    UNION
    #{USER_STATUS_QUERY % { status: 'new' }}
    UNION
    #{USER_STATUS_QUERY % { status: 'active' }}
    UNION
    #{STATUS_QUERY % { status: 'finished' }}
  SQL

  LOGGED_OUT_QUERY = <<~SQL
    #{STATUS_QUERY % { status: 'new' }}
    UNION
    #{STATUS_QUERY % { status: 'active' }}
    UNION
    #{STATUS_QUERY % { status: 'finished' }}
  SQL
  # rubocop:enable Style/FormatString

  def self.home_games(user, **opts)
    opts = {
      personal_offset: opts['personal'],
      new_offset: opts['new'],
      active_offset: opts['active'],
      finished_offset: opts['finished'],
    }.transform_values { |v| v&.to_i || 0 }

    opts[:user_id] = user.id if user
    fetch(user ? LOGGED_IN_QUERY : LOGGED_OUT_QUERY, **opts,).all.sort_by(&:id).reverse
  end

  def ordered_players
    players
      .sort_by(&:id)
      .shuffle(random: Random.new(settings['seed'] || 1))
  end

  def to_h(include_actions: false)
    actions_h = include_actions ? actions.map(&:to_h) : []

    {
      id: id,
      description: description,
      user: user.to_h,
      players: ordered_players.map(&:to_h),
      max_players: max_players,
      title: title,
      settings: settings.to_h,
      status: status,
      turn: turn,
      round: round,
      acting: acting.to_a,
      result: result.to_h,
      actions: actions_h,
      loaded: include_actions,
      created_at: pp_created_at,
      updated_at: pp_updated_at,
    }
  end
end
