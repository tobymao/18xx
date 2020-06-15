# frozen_string_literal: true

Base = Class.new Sequel::Model

class Base
  def pp_created_at
    created_at&.to_i
  end

  def pp_updated_at
    updated_at&.to_i
  end
end
