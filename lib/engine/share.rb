# frozen_string_literal: true

require_relative 'ownable'
require_relative 'share_bundle'

module Engine
  class Share
    include Ownable

    attr_accessor :percent
    attr_reader :corporation, :president

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
      @percent / corporation.share_percent
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

    def to_bundle
      ShareBundle.new(self)
    end
  end
end
