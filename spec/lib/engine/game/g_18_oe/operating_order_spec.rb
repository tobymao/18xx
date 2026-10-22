# frozen_string_literal: true

require 'spec_helper'
require_relative 'helpers'

describe 'G18OE operating order (§11)' do
  include G18OESpecHelpers

  let(:game) { game_at_sr2 }

  def convert_current!
    player = game.current_entity
    convert!(game, game.corporations.find { |c| c.type == :regional && c.president?(player) })
  end

  def place!(corporation, row, column)
    game.stock_market.move(corporation, [row, column])
  end

  it 'runs minors and regionals first, in the order they floated' do
    game = game_at_or1

    expect(game.operating_order.first(30)).to eq(game.minor_regional_order)
  end

  it 'runs majors after the minors and regionals, highest share value first' do
    first = convert_current!
    second = convert_current!
    place!(second, 0, 2)
    order = game.operating_order

    expect(order.last(2)).to eq([second, first])
    expect(order.first(28)).to eq(game.minor_regional_order)
  end

  it 'runs the major further right first when share values tie' do
    left = convert_current!
    right = convert_current!
    place!(left, 1, 1)
    place!(right, 3, 3)

    expect(game.operating_order.last(2)).to eq([right, left])
  end

  it 'only lets majors issue or redeem shares (§11.7)' do
    regional = game.corporations.find { |c| c.type == :regional }

    expect(game.issuable_shares(regional)).to eq([])
    expect(game.redeemable_shares(regional)).to eq([])
  end

  it 'keeps issued shares within the Open Market limit (§10.1, §11.7)' do
    major = convert_current!
    bundles = game.issuable_shares(major)

    expect(bundles).not_to be_empty
    expect(bundles.map(&:percent).max).to eq(50)
    expect(bundles).to all(satisfy { |b| game.share_pool.fit_in_bank?(b) })
  end
end
