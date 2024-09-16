# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G1837
      class Corporation < Engine::Corporation
        def initialize(sym:, name:, **opts)
          ipo_shares = opts[:ipo_shares] || []
          reserved_shares = opts[:reserved_shares] || []
          opts[:shares] = ipo_shares + reserved_shares if !ipo_shares.empty? || !reserved_shares.empty?
          super(sym: sym, name: name, **opts)

          @percent_total_ipo_shares = 100 - reserved_shares.sum
          reserved_shares.each do |share_percent|
            share = shares.reverse.find { |s| s.percent == share_percent && s.buyable }
            share.buyable = false
          end
        end

        def floated?
          return false unless @floatable

          @floated ||= (percent_to_float <= 0)
        end

        def float!
          @floated = true
        end

        def percent_to_float
          return 0 if @floated

          [@float_percent - (@percent_total_ipo_shares - percent_ipo_buyable), 0].max
        end

        def percent_ipo_buyable
          @ipo_owner.shares_by_corporation[self].select(&:buyable).sum(&:percent)
        end

        def total_ipo_shares
          @percent_total_ipo_shares / share_percent
        end
      end
    end
  end
end
