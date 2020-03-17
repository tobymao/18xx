# frozen_string_literal: true

module Engine
  module Ownable
    attr_accessor :owner

    def owned_by?(entity)
      return false unless entity

      owner == entity || owner&.owner == entity || owner == entity&.owner
    end

    def player
      owner.is_a?(Player) ? owner : owner&.player
    end

    def owned_by_corporation?
      owner.is_a?(Corporation)
    end
  end
end
