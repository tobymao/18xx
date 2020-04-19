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

    def price
      @shares.first.price_per_share * num_shares
    end
  end
end
