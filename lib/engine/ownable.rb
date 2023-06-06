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
      owner_chain = [owner]
      test_owner = owner
      until test_owner&.player?
        return nil unless test_owner&.owner

        test_owner = test_owner.owner
        return nil if owner_chain.include?(test_owner)

        owner_chain << test_owner
      end
      test_owner
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
