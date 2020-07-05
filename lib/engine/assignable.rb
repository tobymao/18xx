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

    def self.remove_from_all!(assignables, key)
      assignables.each do |assignable|
        if assignable.assigned?(key)
          assignable.remove_assignment!(key)
          yield assignable if block_given?
        end
      end
    end
  end
end
