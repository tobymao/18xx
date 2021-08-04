# frozen_string_literal: true

require './models/base'
require 'date'

class Session < Base
  many_to_one :user

  EXPIRE_TIME = 180

  def validate
    super
    validates_presence(%i[token user_id])
  end

  def valid?
    created_at.to_datetime > Date.today - EXPIRE_TIME
  end

  def inspect
    "#{self.class.name} - id: #{id}"
  end
end
