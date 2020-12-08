# frozen_string_literal: true

#
# This module is used in classes that need to support
# swapping of shares.
module SwapBuySell
  # Check if it is possible to buy an NdM IPO or Pool share of 10%
  # when player swaps in a 5% share.
  def swap_buy(player, corporation, ipo_or_pool_share)
    return if @game.ndm != corporation || ipo_or_pool_share.percent != 10

    swap_share = player.shares_of(corporation).find { |s| s.percent == 5 }
    return unless swap_share

    # If we were allowed to buy another 5% then swap is OK.
    # We test that a reduced buy of 5% would be allowed.
    can_buy?(player, bundle_reduced_five_percent([ipo_or_pool_share])) ? swap_share : nil
  end

  # Check if it is possible to sell an NdM bundle if player swap 5% share from pool
  def swap_sell(player, corporation, bundle, pool_share)
    return if @game.ndm != corporation || pool_share.percent != 5 || bundle.percent == 5

    # If we were allowed to buy another 5% then swap is OK. Test this by
    # creating a new bundle where one of the shares has its percentage reduced
    # by 5. This way we can test if the swap will not exceed market limit of 50%.
    can_sell?(player, bundle_reduced_five_percent(bundle.shares)) ? pool_share : nil
  end

  # Private method used by other methods in this module
  def bundle_reduced_five_percent(shares)
    # Dup is needed to avoid affecting the actual percentage in the original bundle
    updated_bundle = Engine::ShareBundle.new(shares.map(&:dup))
    updated_bundle.shares.first.percent -= 5
    updated_bundle
  end
end
