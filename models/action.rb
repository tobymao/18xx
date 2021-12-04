# frozen_string_literal: true

require_relative 'base'

class Action < Base
  many_to_one :game
  many_to_one :user

  unrestrict_primary_key

  def before_create
    action.delete('id')
    action.delete('user')
    action.delete('created_at')
    action.delete('meta')
    action.delete('_client_id')
    super
  end

  def to_h
    action.to_h.merge('id' => action_id, 'user' => user_id, 'created_at' => created_at_ts)
  end
end
