# frozen_string_literal: true

require_relative 'base'

class Action < Base
  many_to_one :game
  many_to_one :user

  def before_create
    action.delete('user')
    super
  end

  def to_h
    action.to_h.merge('user' => user_id).merge(created_at: created_at_ts)
  end
end
