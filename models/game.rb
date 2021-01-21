# frozen_string_literal: true

require_relative 'base'

class Game < Base
  many_to_one :user
  one_to_many :actions, order: :action_id
  one_to_many :game_users
  many_to_many :players, class: :User, right_key: :user_id, join_table: :game_users

  QUERY_LIMIT = 13
  PERSONAL_QUERY_LIMIT = 9

  FILTER_QUERY = <<~SQL
    SELECT *
    FROM (SELECT g.*,
        setweight(to_tsvector(g.title), 'A') ||
        setweight(to_tsvector(g.round), 'D') ||
        setweight(to_tsvector(g.description), 'C') ||
        setweight(to_tsvector(coalesce(string_agg(u.name, ' '))), 'B') as ts_vector
       FROM games g
       JOIN game_users gu ON g.id = gu.game_id
       JOIN users u ON u.id = gu.user_id
       GROUP BY g.id) g_search
    WHERE g_search.ts_vector @@ to_tsquery('(183:* & (test | local2)) | !Auction')
    ORDER BY ts_rank(g_search.ts_vector, to_tsquery('(183:* & (test | local2)) | !Auction')) DESC, updated_at DESC;
  SQL

  ALL_GAMES_QUERY = <<~SQL
    SELECT *
    FROM games
    WHERE status = :status
      AND (settings->>'unlisted')::boolean = false
    ORDER BY updated_at DESC
    LIMIT #{QUERY_LIMIT}
    OFFSET :page * #{QUERY_LIMIT - 1}
  SQL

  NON_PERSONAL_GAMES_QUERY = <<~SQL
    WITH user_games AS (
      SELECT game_id AS id
      FROM game_users
      WHERE user_id = :user_id
    )

    SELECT g.*
    FROM games g
    LEFT JOIN user_games ug
      ON g.id = ug.id
    WHERE g.status = :status
      AND ug.id IS NULL
      AND (settings->>'unlisted')::boolean = false
    ORDER BY g.updated_at DESC
    LIMIT #{QUERY_LIMIT}
    OFFSET :page * #{QUERY_LIMIT - 1}
  SQL

  PERSONAL_GAMES_QUERY = <<~SQL
    WITH user_games AS (
      SELECT game_id AS id
      FROM game_users
      WHERE user_id = :user_id
    )
    , filtered_games AS (
      SELECT id, user_id, description, title, max_players, settings, status, turn, round, acting, result, created_at, updated_at
      FROM (SELECT g.*,
          setweight(to_tsvector(g.title), 'A') ||
          setweight(to_tsvector(g.round), 'D') ||
          setweight(to_tsvector(g.description), 'C') ||
          setweight(to_tsvector(coalesce(string_agg(u.name, ' '))), 'B') as ts_vector
         FROM games g
         JOIN game_users gu ON g.id = gu.game_id
         JOIN users u ON u.id = gu.user_id
         GROUP BY g.id) g_search
      WHERE g_search.ts_vector @@ to_tsquery(:search_string)
      ORDER BY ts_rank(g_search.ts_vector, to_tsquery(:search_string)) DESC, updated_at DESC
      /* WHERE g_search.ts_vector @@ to_tsquery('(183:* & (test | local2)) | !Auction') */
    )

    SELECT g.*
    FROM filtered_games g
    JOIN user_games ug
      ON g.id = ug.id
    WHERE g.status = :status
    ORDER BY g.acting && '{:user_id}' DESC, g.updated_at DESC
    LIMIT #{PERSONAL_QUERY_LIMIT}
    OFFSET :page * #{PERSONAL_QUERY_LIMIT - 1}
  SQL

  def self.home_games(user, **opts)
    opts = {
      type: opts['games'] || (user ? 'personal' : 'all'),
      page: opts['p']&.to_i || 0,
      status: opts['status'] || (user ? 'active' : 'new'),
      search_string: opts['s'] || '1:*',
    }
    opts[:user_id] = user.id if user

    query =
      if user && opts[:type] == 'personal'
        PERSONAL_GAMES_QUERY
      elsif user
        NON_PERSONAL_GAMES_QUERY
      else
        ALL_GAMES_QUERY
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
