# frozen_string_literal: true

require_relative 'base'

class Game < Base
  many_to_one :user
  one_to_many :actions, order: :action_id
  one_to_many :game_users
  many_to_many :players, class: :User, right_key: :user_id, join_table: :game_users

  def to_h(include_actions: false)
    seed = settings['seed'] || 1

    h = {
      id: id,
      user: user.to_h,
      players: players.sort_by(&:id).shuffle(random: Random.new(seed)).map(&:to_h),
      max_players: max_players,
      title: title,
      settings: settings,
      status: status,
      turn: turn,
      round: round,
      acting: acting,
      result: result,
      created_at: pp_created_at,
      updated_at: pp_updated_at,
    }

    h[:actions] = actions.map(&:to_h) if include_actions

    h
  end
end
