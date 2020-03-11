# frozen_string_literal: true

require 'engine/ownable'

module Engine
  class Share
    include Ownable

    attr_accessor :index, :owner, :president
    attr_reader :corporation, :percent

    def initialize(corporation, owner: nil, president: false, percent: 10)
      @corporation = corporation
      @president = president
      @percent = percent
      @owner = owner || corporation
      @index = 0
    end

    def name
      "#{@corporation.name}_#{@index}"
    end

    def price
      share_price = @owner == corporation ? corporation.par_price : corporation.share_price
      share_price.price * @percent / 10
    end
  end
end
