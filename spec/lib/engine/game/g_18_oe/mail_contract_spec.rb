# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE Minor K mail contract (§15.10)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }
  let(:mail) { game.company_by_id('MAIL') }
  let(:k) { game.corporation_by_id('K') }

  it 'is owned by minor K and not auctioned' do
    expect(mail.owner).to eq(k)
    expect(k.companies).to include(mail)
    expect(game.initial_auction_companies).not_to include(mail)
  end

  it 'pays nothing while K is unfloated' do
    expect { game.payout_companies }.not_to(change { k.cash })
  end

  it 'pays a floated K 20 pounds in Phase 2' do
    start_minor!(game, 'K', player, 'UK')
    expect { game.payout_companies }.to change { k.cash }.by(20)
  end

  it 'steps up to 40, 50 and 60 pounds in Phases 3, 5 and 7' do
    start_minor!(game, 'K', player, 'UK')
    revenues = []
    6.times do
      game.phase.next!
      revenues << mail.revenue
    end
    expect(revenues).to eq([40, 40, 50, 50, 60, 60])
  end

  it 'pays nothing once K is abandoned' do
    start_minor!(game, 'K', player, 'UK')
    game.abandon_minor!(k)
    expect { game.payout_companies }.not_to(change { k.cash })
  end

  it 'goes to the major K merges into' do
    start_minor!(game, 'K', player, 'UK')
    major = start_major!(game, 'LNWR', player)
    game.add_minor_charter!(k, major)
    game.close_corporation(k, quiet: true)
    expect(mail.owner).to eq(major)
    expect(mail).not_to be_closed
    expect { game.payout_companies }.to change { major.cash }.by(20)
  end

  it 'goes to the major that buys abandoned K' do
    start_minor!(game, 'K', player, 'UK')
    major = start_major!(game, 'LNWR', player)
    game.abandon_minor!(k)
    game.add_minor_charter!(k, major)
    game.close_corporation(k, quiet: true)
    expect(mail.owner).to eq(major)
    expect { game.payout_companies }.to change { major.cash }.by(20)
  end
end
