# frozen_string_literal: true

module Engine
  module Assignable
    def assignments
      @assignments ||= {}
    end

    def assignment_stack_groups
      @assignment_stack_groups ||= {}
    end

    def assigned?(key)
      assignments.key?(key)
    end

    def assign!(key, value = true, stack_group: 'NONE')
      assignments[key] = value
      assignment_stack_groups[stack_group] ||= {}
      assignment_stack_groups[stack_group][key] = value
    end

    def remove_assignment!(key)
      assignments.delete(key)
      assignment_stack_groups.each { |groups| groups.delete(key) }
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
