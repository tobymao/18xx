# frozen_string_literal: true

module Engine
  module ShareHolder
    def shares
      shares_by_corporation.values.flatten
    end

    def shares_by_corporation
      @shares_by_corporation ||= Hash.new { |h, k| h[k] = [] }
    end

    def shares_of(corporation)
      return [] unless corporation

      shares_by_corporation[corporation]
    end

    def percent_of(corporation)
      return 0 unless corporation

      shares_by_corporation[corporation].sum(&:percent)
    end

    def transfer_share(share, to_entity, spender = nil, receiver = nil)
      corporation = share.corporation
      owner = share.owner

      corporation.share_holders[owner] -= share.percent if owner.player?
      corporation.share_holders[to_entity] += share.percent if to_entity.player?
      owner.shares_by_corporation[corporation].delete(share)

      spender.spend(share.price, receiver) if spender && receiver

      to_entity.shares_by_corporation[corporation] << share
      share.owner = to_entity
      share.corporation.owner = to_entity if share.president
    end
  end
end
