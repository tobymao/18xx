# frozen_string_literal: true

module Engine
  module Abilities
    def init_abilities(abilities)
      abilities ||= []

      @abilities = abilities
        .map(&:dup)
        .group_by { |ability| ability[:type] }
        .transform_values!(&:first)
    end

    def abilities(type)
      return nil unless (ability = @abilities[type])

      correct_owner_type =
        case ability[:owner_type]
        when :player
          !owner || owner.player?
        when :corporation
          owner&.corporation?
        when nil
          true
        end

      correct_owner_type ? ability : nil
    end

    def remove_ability(type)
      @abilities.delete(type)
    end

    def remove_ability_when(time)
      @abilities.dup.each do |type, ability|
        remove_ability(type) if ability[:when] == time
      end
    end

    def all_abilities
      @abilities.map { |type, _| abilities(type) }.compact
    end
  end
end
