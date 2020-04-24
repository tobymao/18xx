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
      settings: settings.to_h,
      status: status,
      turn: turn,
      round: round,
      acting: acting.to_a,
      result: result.to_h,
      actions: actions_h,
      created_at: pp_created_at,
      updated_at: pp_updated_at,
    }
  end
end
