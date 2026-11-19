# frozen_string_literal: true

require './models/base'

class Ban < Base
  many_to_one :user
  many_to_one :admin, class: :User, key: :created_by

  def self.banned_account?(user_id)
    !first(user_id: user_id).nil?
  end

  def self.banned_ip?(ip)
    return false if ip.to_s.empty?

    !first(ip: ip).nil?
  end

  def to_h
    {
      id: id,
      user_id: user_id,
      user_name: user&.name,
      ip: ip,
      reason: reason,
      created_by: admin&.name,
      created_at: created_at&.to_i,
    }
  end
end
