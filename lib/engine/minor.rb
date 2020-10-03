# frozen_string_literal: true

require_relative 'assignable'
require_relative 'abilities'
require_relative 'entity'
require_relative 'ownable'
require_relative 'passer'
require_relative 'spender'
require_relative 'operator'

module Engine
  class Minor
    include Abilities
    include Assignable
    include Entity
    include Operator
    include Ownable
    include Passer
    include Spender

    attr_reader :name, :full_name

    def initialize(sym:, name:, **opts)
      @name = sym
      @full_name = name
      @floated = false
      init_operator(opts)
      init_abilities(opts[:abilities])
    end

    def abilities(_type); end

    def companies
      @companies ||= []
    end

    def id
      @name
    end

    def minor?
      true
    end

    def total_shares
      1
    end

    def floated?
      @floated
    end

    def float!
      @floated = true
    end

    def inspect
      "<#{self.class.name}: #{id}>"
    end
  end
end
