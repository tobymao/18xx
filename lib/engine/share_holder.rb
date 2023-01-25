# frozen_string_literal: true

module Engine
  module ShareHolder
    def shares
      shares_by_corporation.values.flatten
    end

    def shares_by_corporation(sorted: false)
      @shares_by_corporation ||= Hash.new { |h, k| h[k] = [] }
      if sorted
        default_proc = @shares_by_corporation.default_proc
        @shares_by_corporation = @shares_by_corporation.to_a.sort.to_h
        @shares_by_corporation.default_proc = default_proc
      end
      @shares_by_corporation
    end

    def shares_of(corporation)
      return [] unless corporation

      shares_by_corporation[corporation]
    end

    def delete_share!(share)
      @shares_by_corporation[share.corporation].reject! { |s| s == share }
    end

    def certs_of(corporation)
      shares_of(corporation)
    end

    def percent_of(corporation)
      return 0 unless corporation

      shares_by_corporation[corporation].sum(&:percent)
    end

    # Same as percent_of, except preferred shares don't count
    def common_percent_of(corporation)
      return 0 unless corporation

      shares_by_corporation[corporation].reject(&:preferred).sum(&:percent)
    end

    def presidencies
      @shares_by_corporation.select { |_c, shares| shares.any?(&:president) }.keys
    end

    def num_shares_of(corporation, ceil: true)
      num = percent_of(corporation).to_f / corporation.share_percent
      ceil ? num.ceil : num
    end
  end
end
