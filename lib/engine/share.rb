# frozen_string_literal: true

require_relative 'ownable'

module Engine
  class Share
    include Ownable

    attr_reader :corporation, :percent, :president

    def initialize(corporation, owner: nil, president: false, percent: 10, index: 0)
      @corporation = corporation
      @president = president
      @percent = percent
      @owner = owner || corporation
      @index = index
    end

    def id
      "#{@corporation.id}_#{@index}"
    end

    def num_shares
      @percent / 10
    end

    def price_per_share
      share_price = @owner == corporation ? corporation.par_price : corporation.share_price
      share_price&.price || corporation.min_price
    end

    def price
      price_per_share * num_shares
    end

    def to_s
      "#{self.class.name} - #{id}"
    end
  end
end
