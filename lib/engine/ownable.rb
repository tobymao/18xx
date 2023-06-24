# frozen_string_literal: true

module Engine
  module Ownable
    attr_accessor :owner

    def owned_by?(entity)
      return false unless entity

      owner == entity || owner&.owner == entity || owner == entity&.owner
    end

    # avoid infinite recursion for 1841
    def player
      chain = { owner => true }
      current = owner
      until current&.player?
        return nil unless current&.owner

        current = current.owner
        return nil if chain[current]

        chain[current] = true
      end
      current
    end

    def corporation
      corporation? ? self : owner&.corporation
    end

    def owned_by_corporation?
      owner&.corporation?
    end

    def owned_by_player?
      owner&.player?
    end

    def corporation?
      false
    end
  end
end
