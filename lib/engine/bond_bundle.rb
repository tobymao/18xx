# frozen_string_literal: true

module Engine
  class BondBundle
    attr_reader :bonds, :count, :value

    def initialize(bonds)
      @bonds = Array(bonds).dup
      raise 'All bonds must be from the same issuer' unless @bonds.map(&:issuer).uniq.one?
      raise 'All bonds must be owned by the same owner' unless @bonds.map(&:owner).uniq.one?

      @count = @bonds.size
      @value = @bonds.sum(&:value)
    end

    def issuer
      @bonds.first.issuer
    end

    def owner
      @bonds.first.owner
    end

    def to_bundle
      self
    end
  end
end
