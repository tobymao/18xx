# frozen_string_literal: true

module Engine
  class ShareBundle
    attr_reader :shares, :percent

    def initialize(shares, percent = nil)
      shares = Array(shares)
      raise 'All shares must be from the same corporation' unless shares.map(&:corporation).uniq.size == 1

      @shares = shares
      @percent = percent || @shares.sum(&:percent)
    end

    def num_shares
      @percent / 10
    end

    def partial?
      @percent != @shares.sum(&:percent)
    end

    def corporation
      @shares.first.corporation
    end

    def owner
      @shares.first.owner
    end

    def president
      corporation.owner
    end

    def presidents_share
      @shares.find(&:president)
    end

    def price_per_share
      @shares.first.price_per_share
    end

    def price
      price_per_share * num_shares
    end

    def liquid_bundle?(turn, share_pool, entity)
      return false unless turn > 1

      fit_in_bank?(share_pool) && can_dump?(entity)
    end

    def fit_in_bank?(share_pool)
      (percent + share_pool.percent_of(corporation)) <= 50
    end

    def can_dump?(entity)
      !presidents_share || (corporation.share_holders.reject { |k, _| k == entity }.values.max || 0) > 10
    end
  end
end
