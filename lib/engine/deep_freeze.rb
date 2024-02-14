# frozen_string_literal: true

class Object
  def deep_freeze
    each(&:deep_freeze) if respond_to?(:each)
    freeze unless frozen?
  end
end
