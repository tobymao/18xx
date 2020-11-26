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
      'Market'
    end

    def player
      nil
    end

    def owner
      nil
    end

    def buy_shares(entity, shares, exchange: nil, exchange_price: nil, swap: nil)
      bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)
      @game.game_error('Cannot buy share from player') if entity.player? && shares.owner.player?

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

      share_str = "a #{bundle.percent}% share"
      share_str += "of #{corporation.name}" unless entity == corporation
      incremental = corporation.capitalization == :incremental

      from = "the #{@game.ipo_name(corporation)}" if bundle.owner.corporation?
      from = bundle.owner.name if bundle.owner.player?
      from ||= 'the market'
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
        price -= swap.price if swap
        swap_text = swap ? " + swap of a #{swap.percent}% share" : ''
        verb = entity == corporation ? 'redeems' : 'buys'
        @log << "#{entity.name} #{verb} #{share_str} "\
          "from #{from} "\
          "for #{@game.format_currency(price)}#{swap_text}"
      end

      if price.zero?
        transfer_shares(bundle, entity)
      else
        transfer_shares(
          bundle,
          entity,
          spender: entity == self ? @bank : entity,
          receiver: incremental && bundle.owner.corporation? ? bundle.owner : @bank,
          price: price,
          swap: swap,
          swap_to_entity: swap ? self : nil
        )
      end

      @game.float_corporation(corporation) unless floated == corporation.floated?
    end

    def sell_shares(bundle, allow_president_change: true, swap: nil)
      entity = bundle.owner

      verb = entity.corporation? ? 'issues' : 'sells'

      price = bundle.price
      price -= swap.price if swap
      swap_text = swap ? " and a #{swap.percent}% share" : ''
      swap_to_entity = swap ? entity : nil

      @log << "#{entity.name} #{verb} #{num_presentation(bundle)} " \
        "of #{bundle.corporation.name} and receives #{@game.format_currency(price)}#{swap_text}"

      transfer_shares(bundle,
                      self,
                      spender: @bank,
                      receiver: entity,
                      price: price,
                      allow_president_change: allow_president_change,
                      swap: swap,
                      swap_to_entity: swap_to_entity)
    end

    def share_pool?
      true
    end

    def fit_in_bank?(bundle)
      (bundle.percent + percent_of(bundle.corporation)) <= @game.class::MARKET_SHARE_LIMIT
    end

    def bank_at_limit?(corporation)
      percent_of(corporation) >= @game.class::MARKET_SHARE_LIMIT
    end

    def transfer_shares(bundle, to_entity,
                        spender: nil,
                        receiver: nil,
                        price: nil,
                        allow_president_change: true,
                        swap: nil,
                        swap_to_entity: nil)
      corporation = bundle.corporation
      owner = bundle.owner
      previous_president = bundle.president
      percent = bundle.percent
      percent -= swap.percent if swap
      price ||= swap ? bundle.price - swap.price : bundle.price

      corporation.share_holders[owner] -= percent
      corporation.share_holders[to_entity] += percent

      spender.spend(price, receiver) if spender && receiver && price.positive?
      bundle.shares.each { |s| move_share(s, to_entity) }
      move_share(swap, swap_to_entity) if swap

      return unless allow_president_change

      # check if we need to change presidency
      max_shares = corporation.player_share_holders.values.max

      majority_share_holders = corporation
        .player_share_holders
        .select { |_, p| p == max_shares }
        .keys

      return if majority_share_holders.any? { |player| player == previous_president }

      president = majority_share_holders
        .select { |p| p.percent_of(corporation) >= corporation.presidents_percent }
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
      swap_to = previous_president.percent_of(corporation) >= presidents_share.percent ? previous_president : self

      change_president(presidents_share, swap_to, president)

      return unless bundle.partial?

      difference = bundle.shares.sum(&:percent) - bundle.percent
      num_shares = difference / corporation.share_percent
      num_shares.times { move_share(shares_of(corporation).first, owner) }
    end

    def change_president(presidents_share, swap_to, president)
      corporation = presidents_share.corporation

      num_shares = presidents_share.percent / corporation.share_percent

      possible_reorder(president.shares_of(corporation)).take(num_shares).each { |s| move_share(s, swap_to) }
      move_share(presidents_share, president)
    end

    def possible_reorder(shares)
      shares
    end

    private

    def distance(player_a, player_b)
      return 0 if !player_a || !player_b

      entities = @game.players.reject(&:bankrupt)
      a = entities.find_index(player_a)
      b = entities.find_index(player_b)
      a < b ? b - a : b - (a - entities.size)
    end

    def move_share(share, to_entity)
      corporation = share.corporation
      share.owner.shares_by_corporation[corporation].delete(share)
      to_entity.shares_by_corporation[corporation] << share
      share.owner = to_entity
    end

    def num_presentation(bundle)
      num_shares = bundle.num_shares
      return "a #{bundle.percent}% share" if num_shares == 1

      "#{num_shares} shares"
    end
  end
end
