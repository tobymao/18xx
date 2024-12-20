# frozen_string_literal: true

require_relative '../trainless_shares_half_value'

module Engine
  module Game
    module G1860
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
            if @optional_rules&.include?(:non_operated_full_value) && corporation.operating_history.empty?
              bundles.each { |b| b.share_price = b.price_per_share.to_i }
            else
              bundles.each { |b| b.share_price = (b.price_per_share / 2).to_i if corporation.trains.empty? }
            end
            bundles
          end
        end

        def player_value(player)
          trainless_shares, train_shares = player.shares.partition { |s| s.corporation.trains.empty? }
          if @optional_rules&.include?(:non_operated_full_value)
            unoperated_corps, operated_corps = trainless_shares.partition { |s| s.corporation.operating_history.empty? }
            player.cash + train_shares.sum(&:price) + unoperated_corps.sum(&:price) + operated_corps.sum do |s|
                                                                                        (s.price / 2).to_i
                                                                                      end + player.companies.sum(&:value)
          else
            player.cash + train_shares.sum(&:price) + trainless_shares.sum do |s|
                                                        (s.price / 2).to_i
                                                      end + player.companies.sum(&:value)
          end
        end
      end
    end
  end
end
