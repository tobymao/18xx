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

    def presidencies
      @shares_by_corporation.select { |_c, shares| shares.any?(&:president) }.keys
    end

    def num_shares_of(corporation)
      percent_of(corporation) / corporation.share_percent
    end

    def bundles_for_corporation(corporation)
      return [] unless corporation.ipoed

      shares = shares_of(corporation).sort_by(&:price)

      bundles = shares.flat_map.with_index do |share, index|
        bundle = shares.take(index + 1)
        percent = bundle.sum(&:percent)
        bundles = [Engine::ShareBundle.new(bundle, percent)]
        if share.president
          normal_percent = corporation.share_percent
          difference = corporation.presidents_percent - normal_percent
          num_partial_bundles = difference / normal_percent
          (1..num_partial_bundles).each do |n|
            bundles.insert(0, Engine::ShareBundle.new(bundle, percent - (normal_percent * n)))
          end
        end
        bundles
      end

      bundles
    end

    def dumpable_bundles(corporation)
      bundles = bundles_for_corporation(corporation)
      bundles.select { |bundle| bundle.can_dump?(self) }
    end
  end
end
