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
      @abilities = {}

      (abilities || []).each do |ability|
        klass = Ability::Base.type(ability[:type])
        ability = Object.const_get("Engine::Ability::#{klass}").new(**ability)
        raise 'Duplicate abilities detected' if @abilities[ability.type]

        ability.owner = self
        @abilities[ability.type] = ability
      end
    end

    def abilities(type, time = nil)
      return nil unless (ability = @abilities[type])

      correct_owner_type =
        case ability.owner_type
        when :player
          !owner || owner.player?
        when :corporation
          owner&.corporation?
        when nil
          true
        end

      return nil if time && ability.when != time.to_s
      return nil unless correct_owner_type

      yield ability if block_given?
      ability
    end

    def add_ability(ability)
      ability.owner = self
      @abilities[ability.type] = ability
    end

    def remove_ability(ability)
      ability.teardown
      @abilities.reject! { |_, a| a == ability }
    end

    def remove_ability_when(time)
      all_abilities.each do |ability|
        remove_ability(ability) if ability.when == time.to_s
      end
    end

    def all_abilities
      @abilities.map { |type, _| abilities(type) }.compact
    end
  end
end
