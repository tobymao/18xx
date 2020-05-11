# frozen_string_literal: true

require_relative 'corporation'
require_relative 'share_bundle'
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
      raise GameError, 'Cannot buy share from player' if share.owner.player?

      share = ShareBundle.new(share)
      corporation = share.corporation
      ipoed = corporation.ipoed
      floated = corporation.floated?

      corporation.ipoed = true if share.presidents_share
      price = share.price

      if ipoed != corporation.ipoed
        @log << "#{entity.name} pars #{corporation.name} at "\
                "#{@game.format_currency(corporation.par_price.price)}"
      end

      if exchange
        @log << "#{entity.name} exchanges #{exchange.name} for a share of #{corporation.name}"
        transfer_shares(share, entity)
      else
        @log << "#{entity.name} buys a #{share.percent}% share of #{corporation.name} "\
          "from #{share.owner.corporation? ? 'the IPO' : 'the market'} "\
          "for #{@game.format_currency(price)}"
        transfer_shares(share, entity, spender: entity, receiver: @bank)
      end

      return if floated == corporation.floated?

      @bank.spend(price * 10, corporation)
      @log << "#{corporation.name} floats with #{@game.format_currency(corporation.cash)} "\
              "and tokens #{corporation.coordinates}"
    end

    def sell_shares(bundle)
      entity = bundle.owner
      num_shares = bundle.num_shares

      @log << "#{entity.name} sells #{num_shares} share#{num_shares > 1 ? 's' : ''} " \
        "#{bundle.corporation.name} and receives #{@game.format_currency(bundle.price)}"

      transfer_shares(bundle, self, spender: @bank, receiver: entity)
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

    private

    def distance(player_a, player_b)
      return 0 if !player_a || !player_b

      entities = @game.round.entities
      a = entities.find_index(player_a)
      b = entities.find_index(player_b)
      a < b ? b - a : b - (a - entities.size)
    end

    def transfer_shares(bundle, to_entity, spender: nil, receiver: nil)
      corporation = bundle.corporation
      owner = bundle.owner
      previous_president = bundle.president
      percent = bundle.percent

      corporation.share_holders[owner] -= percent if owner.player?
      corporation.share_holders[to_entity] += percent if to_entity.player?

      spender.spend(bundle.price, receiver) if spender && receiver
      bundle.shares.each { |s| move_share(s, to_entity) }

      # check if we need to change presidency
      max_shares = corporation.share_holders.values.max

      majority_share_holders = corporation
        .share_holders
        .select { |_, p| p == max_shares }
        .keys

      return if majority_share_holders.any? { |player| player == previous_president }

      president = majority_share_holders
        .select { |p| p.num_shares_of(corporation) > 1 }
        .min_by { |p| distance(previous_president, p) }
      return unless president

      corporation.owner = president
      @log << "#{president.name} becomes the president of #{corporation.name}"

      # skip the president's share swap if the iniator is already the president
      # or there was no previous president. this is because there is no one to swap with
      return if owner == president || !previous_president

      presidents_share = bundle.presidents_share || previous_president.shares_of(corporation).find(&:president)

      # take two shares away from the current president and give it to the
      # previous president if they haven't sold the president's share
      # give the president the president's share
      # if the owner only sold half of their president's share, take one away
      swap_to = previous_president.percent_of(corporation) > 10 ? previous_president : self

      president
        .shares_of(corporation)
        .take(2).each { |s| move_share(s, swap_to) }
      move_share(presidents_share, president)
      move_share(shares_of(corporation).first, owner) if bundle.partial?
    end

    def move_share(share, to_entity)
      corporation = share.corporation
      share.owner.shares_by_corporation[corporation].delete(share)
      to_entity.shares_by_corporation[corporation] << share
      share.owner = to_entity
    end
  end
end
