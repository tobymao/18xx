# frozen_string_literal: true

Base = Class.new Sequel::Model

class Base
  def created_at_ts
    created_at&.to_i
  end

  def updated_at_ts
    updated_at&.to_i
  end
end
