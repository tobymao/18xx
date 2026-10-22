# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE operating order (§11)' do
  include G18OESpecHelpers

  let(:game) { new_game }
  let(:player) { game.players.first }

  def major_at!(id, row, column)
    major = start_major!(game, id, player)
    game.stock_market.move(major, [row, column])
    major
  end

  it 'runs minors and regionals first, in the order they floated' do
    regionals = %w[PLM LNWR SFAI].map { |id| start_regional!(game, id, player) }
    minor = start_minor!(game, 'K', player, 'RU')

    expect(game.operating_order).to eq(regionals + [minor])
  end

  it 'runs majors after the minors and regionals, highest share value first' do
    regional = start_regional!(game, 'PLM', player)
    low = major_at!('LNWR', 5, 2)
    high = major_at!('GWR', 0, 2)

    expect(game.operating_order).to eq([regional, high, low])
  end

  it 'runs the major further right first when share values tie' do
    left = major_at!('LNWR', 1, 1)
    right = major_at!('GWR', 3, 3)

    expect(game.operating_order).to eq([right, left])
  end

  it 'only lets majors issue or redeem shares (§11.7)' do
    regional = start_regional!(game, 'PLM', player)

    expect(game.issuable_shares(regional)).to eq([])
    expect(game.redeemable_shares(regional)).to eq([])
  end

  it 'keeps issued shares within the Open Market limit (§10.1, §11.7)' do
    bundles = game.issuable_shares(start_major!(game, 'LNWR', player))

    expect(bundles.map(&:percent).max).to eq(50)
    expect(bundles).to all(satisfy { |b| game.share_pool.fit_in_bank?(b) })
  end
end
