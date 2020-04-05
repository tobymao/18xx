# frozen_string_literal: true

require 'engine/ownable'

module Engine
  class Company
    include Ownable

    attr_accessor :revenue
    attr_reader :name, :sym, :value, :desc

    def initialize(name:, value:, revenue: 0, desc: '', sym: '', abilities: [])
      @name = name
      @value = value
      @desc = desc
      @revenue = revenue
      @sym = sym
      @open = true

      @abilities = abilities
        .group_by { |ability| ability[:type] }
        .transform_values(&:first)
    end

    def abilities(type)
      return nil unless (ability = @abilities[type])

      correct_owner_type =
        case ability[:owner_type]
        when :player
          owner&.player?
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

    def id
      @name
    end

    def min_bid
      @value
    end

    def min_price
      @value / 2
    end

    def max_price
      @value * 2
    end

    def open?
      @open
    end

    def close!
      @open = false
      owner.companies.delete(self)
    end

    def player?
      false
    end

    def company?
      true
    end

    def corporation?
      false
    end
  end
end
