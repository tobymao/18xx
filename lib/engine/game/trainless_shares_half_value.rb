# frozen_string_literal: true

#
# This module makes the shares of companies without a train worth half the usual value
#
module TrainlessSharesHalfValue
  def bundles_for_corporation(share_holder, corporation, shares: nil)
    return [] unless corporation.ipoed

    shares = (shares || share_holder.shares_of(corporation)).sort_by(&:price)

    shares.flat_map.with_index do |share, index|
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
      bundles.each { |b| b.share_price = (b.price_per_share / 2).to_i if corporation.trains.empty? }
      bundles
    end
  end

  def player_value(player)
    trainless_shares, train_shares = player.shares.partition { |s| s.corporation.trains.empty? }
    player.cash + train_shares.sum(&:price) + trainless_shares.sum { |s| (s.price / 2).to_i } + player.companies.sum(&:value)
  end
end
