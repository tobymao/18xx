# frozen_string_literal: true

Base = Class.new Sequel::Model

class Base
  def pp_created_at
    created_at&.strftime('%Y-%m-%d')
  end

  def pp_created_time
    created_at&.strftime('%T')
  end

  def pp_created_fulldate
    created_at&.strftime('%Y-%m-%d %T')
  end

  def pp_updated_at
    updated_at&.strftime('%Y-%m-%d')
  end

  def pp_updated_time
    updated_at&.strftime('%T')
  end

  def pp_updated_fulldate
    updated_at&.strftime('%Y-%m-%d %T')
  end
end
