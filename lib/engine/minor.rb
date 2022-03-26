# frozen_string_literal: true

require_relative 'assignable'
require_relative 'abilities'
require_relative 'entity'
require_relative 'operator'
require_relative 'ownable'
require_relative 'passer'
require_relative 'spender'

module Engine
  class Minor
    include Abilities
    include Assignable
    include Entity
    include Operator
    include Ownable
    include Passer
    include Spender

    attr_reader :name, :full_name, :type
    attr_accessor :reservation_color

    def initialize(sym:, name:, abilities: [], **opts)
      @name = sym
      @full_name = name
      @floated = false
      @closed = false
      @type = opts[:type]&.to_sym
      @reservation_color = opts[:reservation_color]
      init_operator(opts)
      init_abilities(abilities)
    end

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

    def closed?
      @closed
    end

    def share_price; end

    def par_price; end

    def num_shares_of(_corporation, _ceil = true)
      0
    end

    def share_percent
      100
    end

    def president?(player)
      return false unless player

      owner == player
    end

    def close!
      @closed = true
      @floated = false
      @owner = nil
    end

    def reopen!
      @closed = false
    end
  end
end
