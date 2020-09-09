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

      (abilities || []).each do |ability|
        klass = Ability::Base.type(ability[:type])
        ability = Object.const_get("Engine::Ability::#{klass}").new(**ability)
        ability.owner = self
        @abilities << ability
      end
    end

    def abilities(type, time = nil)
      active_abilities = @abilities.select do |ability|
        next false unless ability.type == type

        next false if time && ability.when && (ability.when != time.to_s)

        usable_this_or = !ability.count_per_or || (ability.count_this_or < ability.count_per_or)
        next false unless usable_this_or

        correct_owner_type =
          case ability.owner_type
          when :player
            !owner || owner.player?
          when :corporation
            owner&.corporation?
          when nil
            true
          end
        next false unless correct_owner_type

        true
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
      all_abilities.each do |ability|
        remove_ability(ability) if ability.when == time.to_s
      end
    end

    def all_abilities
      @abilities.map { |a| abilities(a.type) }.compact
    end

    def reset_ability_count_this_or!
      @abilities.each { |a| a.count_this_or = 0 }
    end
  end
end
