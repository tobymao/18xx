# frozen_string_literal: true

require_relative 'base'

class Game < Base
  many_to_one :user
  one_to_many :actions, order: :action_id
  one_to_many :game_users
  many_to_many :players, class: :User, right_key: :user_id, join_table: :game_users

  QUERY_LIMIT = 13
  PERSONAL_QUERY_LIMIT = 13

  USER_GAMES_IDS = <<~SQL
    SELECT game_id AS id
    FROM game_users
    WHERE user_id = :user_id
  SQL

  FILTERED_GAMES = <<~SQL
    SELECT *
    FROM games
    WHERE status = :status
    AND tsv @@ to_tsquery(:search_string)
  SQL

  ALL_GAMES_SEARCH_QUERY = <<~SQL
    SELECT *
    FROM (#{FILTERED_GAMES}) filtered_games
    WHERE NOT COALESCE((settings->>'unlisted')::boolean, false)
    ORDER BY updated_at DESC
    LIMIT #{QUERY_LIMIT}
    OFFSET :page * #{QUERY_LIMIT - 1}
  SQL

  ALL_GAMES_QUERY = <<~SQL
    SELECT *
    FROM games
    WHERE status = :status
    AND NOT COALESCE((settings->>'unlisted')::boolean, false)
    ORDER BY updated_at DESC
    LIMIT #{QUERY_LIMIT}
    OFFSET :page * #{QUERY_LIMIT - 1}
  SQL

  OTHER_GAMES_SEARCH_QUERY = <<~SQL
    WITH user_games AS (#{USER_GAMES_IDS})
    , filtered_games AS (#{FILTERED_GAMES})
    SELECT g.*
    FROM filtered_games g
    LEFT JOIN user_games ug
      ON g.id = ug.id
    WHERE ug.id IS NULL
      AND NOT COALESCE((settings->>'unlisted')::boolean, false)
    ORDER BY updated_at DESC
    LIMIT #{QUERY_LIMIT}
    OFFSET :page * #{QUERY_LIMIT - 1}
  SQL

  OTHER_GAMES_QUERY = <<~SQL
    WITH user_games AS (#{USER_GAMES_IDS})
    SELECT g.*
    FROM games g
    LEFT JOIN user_games ug
      ON g.id = ug.id
    WHERE ug.id IS NULL
      AND g.status = :status
      AND NOT COALESCE((settings->>'unlisted')::boolean, false)
    ORDER BY updated_at DESC
    LIMIT #{QUERY_LIMIT}
    OFFSET :page * #{QUERY_LIMIT - 1}
  SQL

  PERSONAL_GAMES_SEARCH_QUERY = <<~SQL
    WITH user_games AS (#{USER_GAMES_IDS})
    , filtered_games AS (#{FILTERED_GAMES})
    SELECT g.*
    FROM filtered_games g
    INNER JOIN user_games ug
      ON g.id = ug.id
    ORDER BY g.acting && '{:user_id}' DESC, g.updated_at DESC
    LIMIT #{PERSONAL_QUERY_LIMIT}
    OFFSET :page * #{PERSONAL_QUERY_LIMIT - 1}
  SQL

  PERSONAL_GAMES_QUERY = <<~SQL
    WITH user_games AS (#{USER_GAMES_IDS})
    SELECT g.*
    FROM games g
    INNER JOIN user_games ug
      ON g.id = ug.id
    WHERE g.status = :status
    ORDER BY g.acting && '{:user_id}' DESC, g.updated_at DESC
    LIMIT #{PERSONAL_QUERY_LIMIT}
    OFFSET :page * #{PERSONAL_QUERY_LIMIT - 1}
  SQL

  def self.home_games(user, **opts)
    opts = {
      games: opts['games'] || (user ? 'personal' : 'all'),
      page: opts['p']&.to_i || 0,
      status: opts['status'] || 'active',
      search_string: opts['s'] || nil,
    }
    opts[:user_id] = user.id if user

    query =
      if user && opts[:games] == 'personal'
        opts[:search_string] ? PERSONAL_GAMES_SEARCH_QUERY : PERSONAL_GAMES_QUERY
      elsif user
        opts[:search_string] ? OTHER_GAMES_SEARCH_QUERY : OTHER_GAMES_QUERY
      else
        opts[:search_string] ? ALL_GAMES_SEARCH_QUERY : ALL_GAMES_QUERY
      end

    fetch(query, **opts,).all
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
    players
      .sort_by(&:id)
      .shuffle(random: Random.new(settings['seed'] || 1))
  end

  def archive!
    Action.where(game: self).delete
    update(status: 'archived')
  end

  def to_h(include_actions: false, player: nil)
    actions_h = include_actions ? actions.map(&:to_h) : []
    settings_h = settings.to_h

    # Move user settings and hide from other players
    user_settings_h = settings_h.dig('players', player.to_s)
    settings_h.delete('players')

    {
      id: id,
      description: description,
      user: user.to_h,
      players: ordered_players.map(&:to_h),
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
    }
  end
end
