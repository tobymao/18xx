# frozen_string_literal: true

Base = Class.new Sequel::Model

class Base
  def pp_created_at
    created_at&.strftime('%Y-%m-%-d')
  end

  def pp_updated_at
    updated_at&.strftime('%Y-%m-%-d')
  end
end
