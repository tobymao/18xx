# frozen_string_literal: true

module Engine
  module Assignable
    def assignments
      @assignments ||= {}
    end

    def assigned?(key)
      assignments.key?(key)
    end

    def assign!(key, value = true)
      assignments[key] = value
    end

    def remove_assignment!(key)
      assignments.delete(key)
    end
  end
end
