# frozen_string_literal: true

module Engine
  module Ownable
    def owner
      nil
    end

    def owned_by?(entity)
      return false unless entity

      owner == entity || owner&.owner == entity || owner == entity&.owner
    end

    def player
      owner.is_a?(Player) ? owner : owner&.player
    end

    def owned_by_corporation?
      owner.is_a?(Corporation::Base)
    end
  end
end
