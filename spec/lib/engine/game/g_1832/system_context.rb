# frozen_string_literal: true

module Engine
  RSpec.shared_context 'with a system formed from ACL and SALR' do
    let(:player_a) { game.players[0] }
    let(:player_b) { game.players[1] }
    let(:player_c) { game.players[2] }
    let(:acl) { game.corporation_by_id('ACL') }
    let(:salr) { game.corporation_by_id('SALR') }
    let(:system) { game.corporation_by_id('AMTK') }

    def give(player, shares)
      game.share_pool.buy_shares(player, ShareBundle.new(shares), exchange: :free)
    end

    def act_as(player)
      game.round.instance_variable_set(:@entity_index, game.round.entities.index(player))
      game.round.clear_cache!
    end

    def sell(player, bundle)
      game.process_action(
        Action::SellShares.new(player, shares: bundle.shares, share_price: bundle.share_price, percent: bundle.percent)
      )
    end

    # A holds 20% of each component and B holds only SALR's president's cert. A becomes the system's
    # president by surrendering a VP cert and the SALR shares, which leaves B with a 10% VP cert.
    before do
      game.send(:next_round!) # out of the initial auction, into the first stock round
      game.instance_variable_set(:@turn, 2) # shares can't be sold in the first turn
      par = game.stock_market.par_prices.find { |p| p.price == 100 }
      [acl, salr].each do |corp|
        game.par_corporation(corp, par)
        corp.ipoed = true
      end
      give(player_a, [acl.presidents_share])
      give(player_b, [salr.presidents_share])
      give(player_a, salr.ipo_shares.reject(&:president).first(2))
      give(player_c, acl.ipo_shares.reject(&:president).first(1))

      game.perform_system_formation(acl, salr, system)
    end
  end
end
