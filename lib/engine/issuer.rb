# frozen_string_literal: true

require_relative 'bond'
require_relative 'bond_owner'
require_relative 'entity'

module Engine
  class Issuer
    include BondOwner
    include Entity

    attr_reader :price, :name, :revenue, :desc, :count, :bonds, :id, :full_name, :color, :text_color
    attr_accessor :value

    def initialize(sym:, name:, value:, revenue: 0, desc: '', **opts)
      @name = sym
      @id = sym
      @full_name = name
      @value = value
      @revenue = revenue
      @desc = desc

      @count = opts[:count] || 10
      @bonds = (1..@count).map do |index|
        Bond.new(self, owner: self, index: index)
      end
      @bonds.each { |bond| bonds_by_issuer[self] << bond }

      @color = opts[:color] || :yellow
      @text_color = opts[:text_color] || :black
    end

    def issuer?
      true
    end

    def issuable_bonds
      @bonds.select(&:owned_by_issuer?)
    end

    def inspect
      "<#{self.class.name}: #{id}>"
    end
  end
end
