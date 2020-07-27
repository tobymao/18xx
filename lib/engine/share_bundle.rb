# frozen_string_literal: true

module Engine
  class ShareBundle
    attr_reader :shares, :percent
    attr_accessor :share_price

    def initialize(shares, percent = nil)
      @shares = Array(shares).dup
      raise 'All shares must be from the same corporation' unless @shares.map(&:corporation).uniq.one?

      @percent = percent || @shares.sum(&:percent)
      @share_price = nil
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
      @share_price || @shares.first.price_per_share
    end

    def price
      price_per_share * num_shares
    end

    def can_dump?(entity)
      !presidents_share || (corporation.share_holders.reject { |k, _| k == entity }.values.max || 0) > 10
    end

    def to_bundle
      self
    end

    def ==(other)
      [shares, percent, share_price] == [other.shares, other.percent, other.share_price]
    end
  end
end
