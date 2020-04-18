# frozen_string_literal: true

require_relative 'corporation'
require_relative 'share'
require_relative 'share_holder'

module Engine
  class SharePool
    include ShareHolder
    attr_reader :corporations

    def initialize(game)
      @game = game
      @corporations = game.corporations # used by View::StockRound::render_corporations
      @bank = game.bank
      @log = game.log
    end

    def name
      'Sharepool'
    end

    def buy_share(entity, share, exchange: nil)
      corporation = share.corporation
      ipoed = corporation.ipoed
      floated = corporation.floated?

      corporation.ipoed = true if share.president
      price = share.price

      if ipoed != corporation.ipoed
        @log << "#{entity.name} pars #{corporation.name} at "\
                "#{@game.format_currency(corporation.par_price.price)} and becomes the president"
      end

      if exchange
        transfer_share(share, entity)
        @log << "#{entity.name} exchanges #{exchange.name} for a share of #{corporation.name}"
      else
        transfer_share(share, entity, entity, @bank)
        @log << "#{entity.name} buys a #{share.percent}% share of #{corporation.name} "\
          "for #{@game.format_currency(price)}"
      end

      return if floated == corporation.floated?

      @bank.spend(price * 10, corporation)
      @log << "#{corporation.name} floats with #{@game.format_currency(corporation.cash)} "\
              "and tokens #{corporation.coordinates}"
    end

    def sell_shares(shares)
      share = shares.first
      entity = share.owner
      corporation = share.corporation
      num = shares.size
      percent = shares.sum(&:percent)

      shares.each { |s| transfer_share(s, self, @bank, entity) }

      @log << "#{entity.name} sells #{num} share#{num > 1 ? 's' : ''} " \
        "(%#{percent}) of #{corporation.name} and receives #{@game.format_currency(Engine::Share.price(shares))}"
    end

    def player?
      false
    end

    def corporation?
      false
    end

    def company?
      false
    end
  end
end
