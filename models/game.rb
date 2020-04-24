# frozen_string_literal: true

require_relative 'base'

class Game < Base
  many_to_one :user
  one_to_many :actions, order: :action_id
  one_to_many :game_users
  many_to_many :players, class: :User, right_key: :user_id, join_table: :game_users

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
      settings: settings,
      status: status,
      turn: turn,
      round: round,
      acting: acting,
      # can't get result hash to compile in minijs
      result_str: result&.sort_by { |_, v| -v }&.map { |p, v| "#{p} (#{v})" }&.join(', '),
      actions: actions_h,
      created_at: pp_created_at,
      updated_at: pp_updated_at,
    }
  end
end
