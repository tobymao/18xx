# frozen_string_literal: true

require_relative 'bond_bundle'
require_relative 'ownable'

module Engine
  class Bond
    include Ownable

    attr_accessor :buyable, :cert_size
    attr_reader :issuer, :index

    def initialize(issuer, owner: nil, index: 0, cert_size: 1)
      @cert_size = cert_size
      @issuer = issuer
      @owner = owner || issuer
      @index = index
    end

    def id
      "#{@issuer.id}_#{@index}"
    end

    def owned_by_issuer?
      owner&.issuer?
    end

    def to_bundle
      BondBundle.new(self)
    end

    def to_s
      "#{self.class.name} - #{id}"
    end

    def inspect
      "<Bond: #{@cert_size} #{issuer.id}>"
    end

    def value
      @issuer.value
    end
  end
end
