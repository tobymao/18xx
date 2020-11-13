# frozen_string_literal: true

if RUBY_ENGINE == 'opal'
  require_tree 'ability'
else
  require 'require_all'
  require_rel 'ability'
end

module Engine
  module Abilities
    def init_abilities(abilities)
      @abilities = []
      @start_count = nil

      (abilities || []).each do |ability|
        klass = Ability::Base.type(ability[:type])
        ability = Object.const_get("Engine::Ability::#{klass}").new(**ability)
        ability.owner = self
        @abilities << ability
        next unless ability.start_count

        @start_count = ability.start_count
      end
    end

    def abilities(type = nil, time: nil, owner_type: nil, strict_time: false)
      active_abilities = @abilities.select do |ability|
        right_type?(ability, type) &&
          right_owner?(ability, owner_type) &&
          usable_this_or?(ability) &&
          right_time?(ability, time, strict_time) &&
          usable?(ability)
      end

      active_abilities.each { |ability| yield ability } if block_given?

      return nil if active_abilities.none?
      return active_abilities.first if active_abilities.one?

      active_abilities
    end

    def add_ability(ability)
      ability.owner = self
      @abilities << ability
    end

    def remove_ability(ability)
      ability.teardown
      @abilities.reject! { |a| a == ability }
    end

    def remove_ability_when(time)
      @abilities.dup.each do |ability|
        remove_ability(ability) if ability.remove == time.to_s
      end
    end

    def all_abilities
      @abilities
    end

    def reset_ability_count_this_or!
      @abilities.each { |a| a.count_this_or = 0 }
    end

    def ability_uses
      return unless @start_count

      count = [0, @start_count]
      # This assumes that only one ability per company has multiple uses
      # and the ability never separates from the entity
      @abilities.each do |a|
        count = [a.count, a.start_count] if a.start_count
      end
      count
    end

    private

    def right_type?(ability, type)
      type ? ability.type == type : true
    end

    def right_owner?(ability, owner_type)
      correct_owner_type =
        case ability.owner_type
        when :player
          !owner || owner.player?
        when :corporation
          owner&.corporation?
        when nil
          true
        end
      return false unless correct_owner_type
      return false if owner_type && (ability.owner_type.to_s != owner_type.to_s)

      true
    end

    def usable_this_or?(ability)
      !ability.count_per_or || (ability.count_this_or < ability.count_per_or)
    end

    def right_time?(ability, time, strict_time)
      return false if strict_time && !ability.when
      return true unless time

      if ability.when == 'any'
        !strict_time
      elsif ability.when == 'owning_corp_or_turn'
        %w[owning_corp_or_turn track].include?(time)
      else
        ability.when == time.to_s
      end
    end

    def usable?(ability)
      case ability
      when Ability::Token
        return true if ability.hexes.none?

        corporation =
          if ability.owner.is_a?(Corporation)
            ability.owner
          elsif ability.owner.owner.is_a?(Corporation)
            ability.owner.owner
          end
        return true unless corporation

        tokened_hexes = corporation.tokens.select(&:used).map(&:city).map(&:hex).map(&:id)
        (ability.hexes - tokened_hexes).any?
      else
        true
      end
    end
  end
end
