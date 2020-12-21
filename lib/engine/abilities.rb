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

      @start_count = @abilities.map(&:start_count).compact.max
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
      # Shows the ability with the most uses. Assumes
      # the ability never separates from the entity
      @abilities.each do |a|
        count = [a.count, a.start_count] if a.start_count
      end
      count
    end
  end
end
