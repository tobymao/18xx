# frozen_string_literal: true

require_relative 'corporation'
require_relative 'entity'
require_relative 'share_bundle'
require_relative 'share_holder'

module Engine
  class SharePool
    include Entity
    include ShareHolder

    def initialize(game)
      @game = game
      @bank = game.bank
      @log = game.log
    end

    def name
      'Sharepool'
    end

    def buy_shares(entity, shares, exchange: nil, exchange_price: nil)
      bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)
      raise GameError, 'Cannot buy share from player' if shares.owner.player?

      corporation = bundle.corporation
      ipoed = corporation.ipoed
      floated = corporation.floated?

      corporation.ipoed = true if bundle.presidents_share
      price = bundle.price
      par_price = corporation.par_price&.price

      if ipoed != corporation.ipoed
        @log << "#{entity.name} pars #{corporation.name} at "\
                "#{@game.format_currency(par_price)}"
      end

      share_str = "a #{bundle.percent}% share of #{corporation.name}"
      incremental = corporation.capitalization == :incremental

      from = bundle.owner.corporation? ? "the #{@game.class::IPO_NAME}" : 'the market'
      if exchange
        price = exchange_price || 0
        case exchange
        when :free
          @log << "#{entity.name} receives #{share_str}"
        when Company
          @log << if exchange_price
                    "#{entity.name} exchanges #{exchange.name} and #{@game.format_currency(price)}"\
                    " from #{from} for #{share_str}"
                  else
                    "#{entity.name} exchanges #{exchange.name} from #{from} for #{share_str}"
                  end
        end
      else
        @log << "#{entity.name} buys #{share_str} "\
          "from #{from} "\
          "for #{@game.format_currency(price)}"
      end

      if price.zero?
        transfer_shares(bundle, entity)
      else
        transfer_shares(
          bundle,
          entity,
          spender: entity,
          receiver: incremental && bundle.owner.corporation? ? bundle.owner : @bank,
          price: price
        )
      end

      return if floated == corporation.floated?

      @log << "#{corporation.name} floats"

      return if incremental

      @bank.spend(par_price * 10, corporation)
      @log << "#{corporation.name} receives #{@game.format_currency(corporation.cash)}"
    end

    def sell_shares(bundle)
      entity = bundle.owner
      num_shares = bundle.num_shares

      verb = entity.corporation? ? 'issues' : 'sells'

      @log << "#{entity.name} #{verb} #{num_shares} share#{num_shares > 1 ? 's' : ''} " \
        "#{bundle.corporation.name} and receives #{@game.format_currency(bundle.price)}"

      transfer_shares(bundle, self, spender: @bank, receiver: entity)
    end

    def share_pool?
      true
    end

    def fit_in_bank?(bundle)
      (bundle.percent + percent_of(bundle.corporation)) <= 50
    end

    def bank_at_limit?(corporation)
      percent_of(corporation) >= 50
    end

    private

    def distance(player_a, player_b)
      return 0 if !player_a || !player_b

      entities = @game.players.reject(&:bankrupt)
      a = entities.find_index(player_a)
      b = entities.find_index(player_b)
      a < b ? b - a : b - (a - entities.size)
    end

    def transfer_shares(bundle, to_entity, spender: nil, receiver: nil, price: nil)
      corporation = bundle.corporation
      owner = bundle.owner
      previous_president = bundle.president
      percent = bundle.percent
      price ||= bundle.price

      corporation.share_holders[owner] -= percent if owner.player?
      corporation.share_holders[to_entity] += percent if to_entity.player?

      spender.spend(price, receiver) if spender && receiver
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
        .min_by { |p| previous_president == self ? 0 : distance(previous_president, p) }
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
