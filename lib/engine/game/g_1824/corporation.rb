# frozen_string_literal: true

require_relative '../../corporation'

module Engine
  module Game
    module G1824
      class Corporation < Engine::Corporation
        def initialize(sym:, name:, **opts)
          ipo_shares = opts[:ipo_shares] || []
          @reserved_ipo_shares = opts[:reserved_shares] || []

          # Assumption is that reserved share always starts with the president's share
          # In case it is a regional with associated coal mine that is closed,
          # the president's share need to be first to get corrected par (20%)
          opts[:shares] = @reserved_ipo_shares + ipo_shares if !ipo_shares.empty? || !@reserved_ipo_shares.empty?

          super(sym: sym, name: name, **opts)

          @percent_total_ipo_shares = 100 - @reserved_ipo_shares.sum
          @reserved_ipo_shares.each do |share_percent|
            share = shares.find { |s| s.percent == share_percent && s.buyable }
            share.buyable = false
          end
          @real_presidents_percent = @presidents_share.percent
        end

        def floated?
          return false unless @floatable

          @floated ||= (percent_to_float <= 0)
        end

        def float!
          @floated = true
        end

        def percent_ipo_buyable
          @ipo_owner.shares_by_corporation[self].select(&:buyable).sum(&:percent)
        end

        def percent_to_float
          return 0 if @floated

          [@float_percent - (100 - percent_ipo_buyable), 0].max
        end

        def total_ipo_shares
          @percent_total_ipo_shares / share_percent
        end

        # Used when transforming a regional associated to a coal railway
        # to an unassociated regional railway, during initial SR
        def remove_reserve_for_all_shares!
          @floatable = true
          @par_via_exchange = false
          shares.each do |share|
            share.buyable = true
          end
          @percent_total_ipo_shares = 100
          @reserved_ipo_shares = []
          @real_presidents_percent = @presidents_share.percent
        end

        # Used when a pre-staatsbahn is unsold during initial SR.
        # We need to unreserve one of the shares of the national.
        def unreserve_one_share!
          shares.each do |share|
            next if share.buyable

            share.buyable = true
            break
          end
        end

        def should_not_float_until_exchange!
          @floatable = false
          @real_presidents_percent = 100
        end

        def presidents_percent
          # If president's share is reserved we should become president by buying 20% in the corporation.
          # In 1824 this can happen for regional railways which are IPOed by buying a coal railway, and
          # then 10% shares are bought whule presidents share is still reserved for a later exchange.
          @real_presidents_percent
        end

        def prepare_merge!
          @floatable = true
          @percent_total_ipo_shares = 100
          @real_presidents_percent = @presidents_share.percent
        end
      end
    end
  end
end
