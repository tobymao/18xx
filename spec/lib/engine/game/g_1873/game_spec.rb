# frozen_string_literal: true

require 'spec_helper'

describe Engine::Game::G1873::Game do
  it 'records MHE automatic dividends as payouts' do
    game = Engine::Game.load('public/fixtures/1873/1873_game_end_stock_market.json')
    mhe = game.corporation_by_id('MHE')

    expect(mhe.operating_history).not_to be_empty
    expect(mhe.operating_history.values.map(&:dividend_kind).uniq).to eq(['payout'])
  end
end
