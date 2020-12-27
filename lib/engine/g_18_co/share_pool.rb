# frozen_string_literal: true

require_relative '../share_pool'

module Engine
  module G18CO
    class SharePool < SharePool
      def totaling_num(shares, num_shares)
        return [] if shares.empty?
        return [] unless num_shares
        return shares if shares.one?

        percent = num_shares * shares.first.corporation.share_percent
        matching_bundles = (1..shares.size).flat_map do |n|
          shares.combination(n).to_a.select { |b| b.sum(&:percent) == percent }
        end

        # we want the bundle with the most shares, as higher percent in fewer shares in more valuable
        matching_bundles.max_by(&:size)
      end

      def distance(entity_a, entity_b)
        return 0 if !entity_a || !entity_b
        return @game.players.size + 485 - entity_b.share_price.price if entity_b.corporation?

        super
      end
    end
  end
end
