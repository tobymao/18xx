# frozen_string_literal: true

require 'engine/corporation/base'
require 'engine/share'
require 'engine/share_holder'

module Engine
  class SharePool
    include ShareHolder
    attr_reader :corporations

    def initialize(corporations, bank, log)
      @corporations = corporations
      @bank = bank
      @log = log
    end

    def buy_share(entity, share)
      corporation = share.corporation
      ipoed = corporation.ipoed
      floated = corporation.floated?

      corporation.ipoed = true
      transfer_share(share, entity, entity, @bank)

      if ipoed != corporation.ipoed
        @log << "#{entity.name} pars #{corporation.name} at $#{corporation.par_price.price} and becomes the president"
      end

      @log << "#{entity.name} buys a #{share.percent}% share of #{corporation.name} for $#{share.price}"

      return if floated == corporation.floated?

      @bank.spend(corporation.par_price.price * 10, corporation)
      @log << "#{corporation.name} floats with $#{corporation.cash} and tokens #{corporation.coordinates}"
    end

    def sell_shares(shares)
      share = shares.first
      entity = share.owner
      corporation = share.corporation
      num = shares.size
      percent = shares.sum(&:percent)

      shares.each { |s| transfer_share(s, self, @bank, entity) }

      @log << "#{entity.name} sells #{num} share#{num > 1 ? 's' : ''} " \
        "(%#{percent}) of #{corporation.name} and receives $#{Engine::Share.price(shares)}"
    end
  end
end
