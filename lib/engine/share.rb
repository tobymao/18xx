# frozen_string_literal: true

require_relative 'ownable'
require_relative 'share_bundle'

module Engine
  class Share
    include Ownable

    attr_accessor :percent, :buyable, :counts_for_limit
    attr_reader :corporation, :president, :index

    def initialize(corporation, owner: nil, president: false, percent: 10, index: 0)
      @corporation = corporation
      @president = president
      @percent = percent
      @owner = owner || corporation
      @index = index

      # buyable: set to false if the share is reserved (e.g. trade-in)
      @buyable = true

      # counts_for_limit: set to false if share is disregarded for cert limit
      @counts_for_limit = true
    end

    def id
      "#{@corporation.id}_#{@index}"
    end

    def num_shares(ceil: true)
      num = @percent.to_f / corporation.share_percent
      ceil ? num.ceil : num
    end

    def price_per_share
      share_price = @owner == corporation ? corporation.par_price : corporation.share_price
      share_price&.price || corporation.min_price
    end

    def price
      (price_per_share * num_shares(ceil: false)).ceil
    end

    def to_s
      "#{self.class.name} - #{id}"
    end

    def to_bundle
      ShareBundle.new(self)
    end

    def inspect
      "<Share: #{@corporation.id} #{@percent}%>"
    end

    def transfer(new_entity)
      owner.shares_by_corporation[corporation].delete(self)
      corporation.share_holders[owner] -= percent

      @owner = new_entity
      corporation.share_holders[new_entity] += percent
      new_entity.shares_by_corporation[corporation] << self
    end
  end
end
