# frozen_string_literal: true

require_relative '../share_pool'

module Engine
  module G1860
    class SharePool < SharePool
      def buy_shares(entity, shares, exchange: nil, exchange_price: nil, swap: nil)
        bundle = shares.is_a?(ShareBundle) ? shares : ShareBundle.new(shares)
        if bundle.presidents_share && bundle.owner == self
          bundle = ShareBundle.new(bundle.shares, bundle.corporation.share_percent)
        end

        super(entity, bundle, exchange: exchange, exchange_price: exchange_price, swap: swap)
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

        # handle selling president's share to the pool
        # if partial, move shares from pool to old president
        if max_shares <= 10 && bundle.presidents_share && to_entity == self
          corporation.owner = self
          @log << "President's share sold to pool. #{corporation.name} enters receivership"
          return unless bundle.partial?

          difference = bundle.shares.sum(&:percent) - bundle.percent
          num_shares = difference / corporation.share_percent
          num_shares.times { move_share(shares_of(corporation).first, owner) }
          return
        end

        # handle buying president's share from the pool
        # swap existing share for it
        if owner == self && bundle.presidents_share
          corporation.owner = to_entity
          @log << "#{to_entity.name} becomes the president of #{corporation.name}"
          @log << "#{corporation.name} exits receivership"
          # difference = bundle.percent - corporation.share_percent
          difference = bundle.shares.sum(&:percent) - bundle.percent
          num_shares = difference / corporation.share_percent
          num_shares.times { move_share(to_entity.shares_of(corporation).first, self) }
          # corporation.share_holders[to_entity] -= difference
          # corporation.share_holders[self] += difference
          return
        end

        # skip if no player can be president yet
        return if max_shares <= 10

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
    end
  end
end
