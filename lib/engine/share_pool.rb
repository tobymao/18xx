# frozen_string_literal: true

require_relative 'corporation'
require_relative 'entity'
require_relative 'share_bundle'
require_relative 'share_holder'

module Engine
  class SharePool
    include Entity
    include ShareHolder

    def initialize(game, allow_president_sale: false)
      @game = game
      @bank = game.bank
      @log = game.log
      @allow_president_sale = allow_president_sale
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

    def buy_shares(entity, shares, exchange: nil, exchange_price: nil, swap: nil, allow_president_change: true)
      bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)
      if @allow_president_sale && bundle.presidents_share && bundle.owner == self
        bundle = ShareBundle.new(bundle.shares, bundle.corporation.share_percent)
      end

      if !@game.class::CORPORATE_BUY_SHARE_ALLOW_BUY_FROM_PRESIDENT && shares.owner.player?
        raise GameError, 'Cannot buy share from player'
      end

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

      share_str = "a #{bundle.percent}% share "
      share_str += "of #{corporation.name}" unless entity == corporation

      from = if bundle.owner.corporation?
               (bundle.owner == bundle.corporation ? "the #{@game.ipo_name(corporation)}" : bundle.owner.name)
             elsif bundle.owner.player?
               bundle.owner.name
             else
               'the market'
             end

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
        receiver = if corporation.capitalization == :incremental && bundle.owner.corporation? || bundle.owner.player?
                     bundle.owner
                   elsif corporation.capitalization == :escrow && bundle.owner.corporation?
                     # When another game with escrow capitalization is implemented put this into @game
                     bundle.owner
                   else
                     @bank
                   end
        transfer_shares(
          bundle,
          entity,
          spender: entity == self ? @bank : entity,
          receiver: receiver,
          price: price,
          swap: swap,
          swap_to_entity: swap ? self : nil,
          allow_president_change: allow_president_change
        )
      end

      @game.float_corporation(corporation) if corporation.floatable && floated != corporation.floated?
    end

    def sell_shares(bundle, allow_president_change: true, swap: nil)
      entity = bundle.owner

      verb = entity.corporation? && entity == bundle.corporation ? 'issues' : 'sells'

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
      price ||= bundle.price

      corporation.share_holders[owner] -= bundle.percent
      corporation.share_holders[to_entity] += bundle.percent

      if swap
        # Need to handle this separately as transfer and swap
        # might be between different pair (ie player buy from IPO
        # and the player's swap share end up in Market)
        corporation.share_holders[swap.owner] -= swap.percent
        corporation.share_holders[swap_to_entity] += swap.percent
        move_share(swap, swap_to_entity)
      end

      if corporation.capitalization == :escrow && receiver == corporation
        # If another game comes around that needs to work w/ escrow capitalization
        # feel free to put this into the game logic
        if corporation.percent_of(corporation) > 50 && spender && price.positive?
          spender.spend(price, receiver) if spender && receiver
        else
          # In the bottom half of the IPO the funds "are held by the bank in escrow"
          # Record in the corporation that money is in escrow, but move *nothing*
          spender.spend(price, @bank)
          corporation.escrow += price
        end
      elsif spender && receiver && price.positive?
        spender.spend(price, receiver)
      end

      bundle.shares.each { |s| move_share(s, to_entity) }

      return unless allow_president_change

      # check if we need to change presidency
      max_shares = presidency_check_shares(corporation).values.max

      # handle selling president's share to the pool
      # if partial, move shares from pool to old president
      if @allow_president_sale && max_shares <= 10 && bundle.presidents_share && to_entity == self
        corporation.owner = self
        @log << "President's share sold to pool. #{corporation.name} enters receivership"
        return unless bundle.partial?

        handle_partial(bundle, self, owner)
        return
      end

      # handle buying president's share from the pool
      # swap existing share for it
      if @allow_president_sale && owner == self && bundle.presidents_share
        corporation.owner = to_entity
        @log << "#{to_entity.name} becomes the president of #{corporation.name}"
        @log << "#{corporation.name} exits receivership"
        handle_partial(bundle, to_entity, self)
        return
      end

      # skip the rest if no player can be president yet
      return if @allow_president_sale && max_shares <= 10

      majority_share_holders = presidency_check_shares(corporation).select { |_, p| p == max_shares }.keys

      return if majority_share_holders.any? { |player| player == previous_president }

      president = majority_share_holders
        .select { |p| p.percent_of(corporation) >= corporation.presidents_percent }
        .min_by { |p| previous_president == self ? 0 : distance(previous_president, p) }
      return unless president

      corporation.owner = president
      @log << "#{president.name} becomes the president of #{corporation.name}"

      # skip the president's share swap if the initiator is already the president
      # or there was no previous president. this is because there is no one to swap with
      return if owner == president || !previous_president

      presidents_share = bundle.presidents_share || previous_president.shares_of(corporation).find(&:president)

      # Bail out if there is no president's share in the prior president's bundle.
      # This happens during 1856 nationalization sometimes
      return unless presidents_share

      # take two shares away from the current president and give it to the
      # previous president if they haven't sold the president's share
      # give the president the president's share
      # if the owner only sold half of their president's share, take one away
      swap_to = previous_president.percent_of(corporation) >= presidents_share.percent ? previous_president : self

      change_president(presidents_share, swap_to, president, previous_president)

      return unless bundle.partial?

      handle_partial(bundle, self, owner)
    end

    def handle_partial(bundle, from, to)
      corp = bundle.corporation
      difference = bundle.shares.sum(&:percent) - bundle.percent
      num_shares = difference / corp.share_percent
      num_shares.times { move_share(from.shares_of(corp).first, to) }
    end

    def change_president(presidents_share, swap_to, president, _previous_president = nil)
      corporation = presidents_share.corporation

      num_shares = presidents_share.percent / corporation.share_percent

      shares_for_presidency_swap(possible_reorder(president.shares_of(corporation)), num_shares).each do |s|
        move_share(s, swap_to)
      end
      move_share(presidents_share, president)
    end

    def presidency_check_shares(corporation)
      corporation.player_share_holders
    end

    def shares_for_presidency_swap(shares, num_shares)
      shares.take(num_shares)
    end

    def possible_reorder(shares)
      shares
    end

    def distance(player_a, player_b)
      return 0 if !player_a || !player_b

      entities = @game.players.reject(&:bankrupt)
      a = entities.find_index(player_a)
      b = entities.find_index(player_b)
      a < b ? b - a : b - (a - entities.size)
    end

    def inspect
      "<#{self.class.name}>"
    end

    private

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
