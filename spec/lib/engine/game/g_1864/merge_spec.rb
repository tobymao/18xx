# frozen_string_literal: true

require 'spec_helper'

describe 'G1864 merger value' do
  let(:game) { Engine::Game::G1864::Game.new(%w[alice bob carol], seed: 1) }
  let(:merge_step) { Engine::Game::G1864::Step::Merge.new(game, game.round) }
  let(:minors) { game.corporations.select { |c| c.type == :minor }.first(3) }

  def merge_at(*prices)
    merging = minors.first(prices.size).zip(prices).map do |minor, price|
      game.par_corporation(minor, game.stock_market.market.flatten.compact.find { |sp| sp.price == price })
      minor
    end
    merge_step.instance_variable_set(:@merging, merging)
  end

  it 'averages every company in a three way merger' do
    merge_at(100, 90, 45)

    expect(merge_step.merged_par_price.price).to eq(70)
  end

  it 'rounds the average down to a par space' do
    merge_at(100, 80)

    expect(merge_step.merged_par_price.price).to eq(90)
  end

  it 'allows a value as low as $50' do
    merge_at(55, 45)

    expect(merge_step.merged_par_price.price).to eq(50)
  end

  it 'forbids a merger worth less than $50' do
    merge_at(50, 45)

    expect { merge_step.finish_merge }.to raise_error(Engine::GameError, /below \$50/)
  end

  it 'shows the starting price of the major corporation while merging' do
    merge_at(100, 90, 45)

    expect(merge_step.help).to eq('Merging RF&CC ($100), BW&GF ($90), CO&G ($45) - the major corporation will start at $70')
  end

  it 'warns while merging when the value is below $50' do
    merge_at(50, 45)

    expect(merge_step.help).to eq('Merging RF&CC ($50), BW&GF ($45) - the average of $47 is below the $50 minimum, '\
                                  'add more companies to continue')
  end
end
